# Runs the setup script of a Windows case (windows/testdata/<id>/), or undoes
# it; see windows_cases_test.go. A setup is dot-sourced here, elevated, with
# $ErrorActionPreference = 'Stop', and changes settings only through the
# helpers below. Each helper records the setting it replaces in the undo file
# before it changes it, and -Restore puts the recorded settings back, the last
# change first.
#
#   windows-setup.ps1 -Undo <file> -Case <setup.ps1>
#   windows-setup.ps1 -Undo <file> -Restore
param(
    [Parameter(Mandatory = $true)][string]$Undo,
    [string]$Case,
    [switch]$Restore
)

$ErrorActionPreference = 'Stop'

# Skip-Case ends the case without a verdict, for a state this machine cannot provide.
function Skip-Case([string]$Reason) {
    [Console]::Error.WriteLine("SKIP: $Reason")
    exit 77
}

function Add-Undo([hashtable]$Entry) {
    $entries = @()
    if (Test-Path -LiteralPath $Undo) { $entries = @(Import-Clixml -LiteralPath $Undo) }
    $entries += $Entry
    Export-Clixml -LiteralPath $Undo -InputObject $entries
}

function New-CaseTemp {
    $dir = Join-Path ([IO.Path]::GetTempPath()) ("secbaseline-case-" + [guid]::NewGuid().ToString())
    New-Item -ItemType Directory -Path $dir | Out-Null
    return $dir
}

# --- Registry ---------------------------------------------------------------

function Save-RegistryValue([string]$Path, [string]$Name) {
    $entry = @{ Kind = 'registry'; Path = $Path; Name = $Name; Created = $null; Exists = $false }
    # The topmost key that does not exist yet is deleted on restore.
    $key = $Path
    while (-not (Test-Path -LiteralPath $key)) {
        $entry.Created = $key
        $key = Split-Path -Path $key -Parent
    }
    if (-not $entry.Created) {
        $item = Get-Item -LiteralPath $Path
        if ($item.GetValueNames() -contains $Name) {
            $entry.Exists = $true
            $entry.Type = [string]$item.GetValueKind($Name)
            $entry.Value = $item.GetValue($Name, $null, 'DoNotExpandEnvironmentNames')
        }
    }
    Add-Undo $entry
}

# Set-RegistryValue sets a registry value (DWord unless -Type says otherwise),
# creating its key if needed.
function Set-RegistryValue {
    param([string]$Path, [string]$Name, $Value, [string]$Type = 'DWord')
    Save-RegistryValue $Path $Name
    if (-not (Test-Path -LiteralPath $Path)) { New-Item -Path $Path -Force | Out-Null }
    New-ItemProperty -LiteralPath $Path -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null
}

# Remove-RegistryValue deletes a registry value if it exists.
function Remove-RegistryValue([string]$Path, [string]$Name) {
    if (-not (Test-Path -LiteralPath $Path)) { return }
    if ((Get-Item -LiteralPath $Path).GetValueNames() -notcontains $Name) { return }
    Save-RegistryValue $Path $Name
    Remove-ItemProperty -LiteralPath $Path -Name $Name
}

# --- Local security policy (secedit) ----------------------------------------

# Read-SecurityPolicy returns one section of the local security policy
# ('System Access' or 'Privilege Rights') as name -> value text.
function Read-SecurityPolicy([string]$Section) {
    $dir = New-CaseTemp
    try {
        secedit /export /cfg "$dir\export.inf" /areas SECURITYPOLICY USER_RIGHTS /log "$dir\export.log" /quiet | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "secedit /export failed with exit code $LASTEXITCODE" }
        $settings = @{}
        $current = $null
        foreach ($line in Get-Content -LiteralPath "$dir\export.inf") {
            if ($line -match '^\s*\[(.+)\]\s*$') {
                $current = $Matches[1]
            } elseif ($current -eq $Section -and $line -match '^\s*(\w+)\s*=\s*(.*?)\s*$') {
                $settings[$Matches[1]] = $Matches[2]
            }
        }
        return $settings
    } finally {
        Remove-Item -LiteralPath $dir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Write-SecurityPolicy([string]$Section, [string]$Area, [hashtable]$Settings) {
    $dir = New-CaseTemp
    try {
        $lines = @('[Unicode]', 'Unicode=yes', '[Version]', 'signature="$CHICAGO$"', 'Revision=1', "[$Section]")
        foreach ($name in $Settings.Keys) { $lines += "$name = $($Settings[$name])" }
        Set-Content -LiteralPath "$dir\policy.inf" -Value $lines -Encoding Unicode
        secedit /configure /db "$dir\policy.sdb" /cfg "$dir\policy.inf" /areas $Area /log "$dir\policy.log" /quiet | Out-Null
        if ($LASTEXITCODE -ne 0) {
            $log = @(Get-Content -LiteralPath "$dir\policy.log" -ErrorAction SilentlyContinue | Select-Object -Last 20)
            throw "secedit /configure failed with exit code $LASTEXITCODE`n$($log -join "`n")"
        }
    } finally {
        Remove-Item -LiteralPath $dir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Set-SecurityPolicy sets settings of the [System Access] section of the local
# security policy: MinimumPasswordLength, PasswordComplexity, LockoutBadCount, ...
function Set-SecurityPolicy([hashtable]$Settings) {
    $current = Read-SecurityPolicy 'System Access'
    $old = @{}
    foreach ($name in $Settings.Keys) {
        if ($current.ContainsKey($name)) { $old[$name] = $current[$name] }
    }
    Add-Undo @{ Kind = 'policy'; Settings = $old }
    Write-SecurityPolicy 'System Access' 'SECURITYPOLICY' $Settings
    $after = Read-SecurityPolicy 'System Access'
    foreach ($name in $Settings.Keys) {
        if ([string]$after[$name] -ne [string]$Settings[$name]) {
            throw "$name is '$($after[$name])' after secedit /configure, not '$($Settings[$name])'"
        }
    }
}

function Join-Accounts([string]$Value) {
    return ((@($Value -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }) | Sort-Object) -join ',')
}

# Set-UserRight assigns a user right (SeTcbPrivilege, ...) to exactly the
# given accounts, as names or *SIDs; no accounts means no one.
function Set-UserRight([string]$Right, [string[]]$Accounts = @()) {
    $current = Read-SecurityPolicy 'Privilege Rights'
    Add-Undo @{ Kind = 'right'; Right = $Right; Value = [string]$current[$Right] }
    $want = $Accounts -join ','
    Write-SecurityPolicy 'Privilege Rights' 'USER_RIGHTS' @{ $Right = $want }
    $after = [string](Read-SecurityPolicy 'Privilege Rights')[$Right]
    if ((Join-Accounts $after) -ne (Join-Accounts $want)) {
        throw "$Right is assigned to '$after' after secedit /configure, not '$want'"
    }
}

# --- Audit policy -----------------------------------------------------------

function Write-AuditPolicy([string]$Subcategory, [bool]$Success, [bool]$Failure) {
    $s = if ($Success) { 'enable' } else { 'disable' }
    $f = if ($Failure) { 'enable' } else { 'disable' }
    auditpol /set /subcategory:"$Subcategory" /success:$s /failure:$f | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "auditpol /set /subcategory:$Subcategory failed with exit code $LASTEXITCODE" }
}

# Set-AuditPolicy sets an audit subcategory, by its English name, to audit
# success, failure, both (-Success -Failure) or nothing. The checks find
# subcategories by GUID, so naming them here checks those GUIDs too.
function Set-AuditPolicy([string]$Subcategory, [switch]$Success, [switch]$Failure) {
    $row = auditpol /get /subcategory:"$Subcategory" /r | Where-Object { $_ } | ConvertFrom-Csv
    if ($LASTEXITCODE -ne 0 -or -not $row) { throw "auditpol /get /subcategory:$Subcategory failed with exit code $LASTEXITCODE" }
    $old = [string]$row.'Inclusion Setting'
    Add-Undo @{ Kind = 'audit'; Subcategory = $Subcategory; Success = $old -match 'Success'; Failure = $old -match 'Failure' }
    Write-AuditPolicy $Subcategory $Success $Failure
}

# --- Services, firewall, accounts -------------------------------------------

# Set-ServiceStartup sets a service's start type: Automatic, Manual or Disabled.
function Set-ServiceStartup([string]$Name, [string]$StartupType) {
    $service = Get-Service -Name $Name
    Add-Undo @{ Kind = 'service'; Name = $Name; StartupType = [string]$service.StartType }
    Set-Service -Name $Name -StartupType $StartupType
}

# Set-FirewallProfile sets a firewall profile (Domain, Private, Public) in the
# local store to True, False or NotConfigured.
function Set-FirewallProfile([string]$Name, [string]$Enabled) {
    $fw = Get-NetFirewallProfile -Name $Name -PolicyStore PersistentStore
    Add-Undo @{ Kind = 'firewall'; Name = $Name; Enabled = [string]$fw.Enabled }
    Set-NetFirewallProfile -Name $Name -PolicyStore PersistentStore -Enabled $Enabled
}

# Wait-FirewallProfile waits until the firewall service applies a profile's
# state, which it does some time after a policy value changes.
function Wait-FirewallProfile([string]$Name, [bool]$Enabled) {
    $want = if ($Enabled) { 'True' } else { 'False' }
    for ($i = 0; $i -lt 30; $i++) {
        if ([string](Get-NetFirewallProfile -Name $Name -PolicyStore ActiveStore).Enabled -eq $want) { return }
        Start-Sleep -Seconds 1
    }
    Skip-Case "the firewall service did not apply Enabled = $want to the $Name profile"
}

function Get-BuiltinAccount([int]$Rid) {
    $user = Get-LocalUser | Where-Object { $_.SID.Value -match "^S-1-5-21-\d+-\d+-\d+-$Rid$" }
    if (-not $user) { throw "no local account with relative ID $Rid" }
    return $user
}

# Set-BuiltinAccount renames, enables or disables a built-in local account by
# its relative ID: 500 is Administrator, 501 is Guest.
function Set-BuiltinAccount {
    param([int]$Rid, [string]$Name, [Nullable[bool]]$Enabled)
    $user = Get-BuiltinAccount $Rid
    Add-Undo @{ Kind = 'account'; Rid = $Rid; Name = $user.Name; Enabled = [bool]$user.Enabled }
    if ($Name -and $Name -ne $user.Name) { Rename-LocalUser -SID $user.SID -NewName $Name }
    if ($null -ne $Enabled) {
        if ($Enabled) { Enable-LocalUser -SID $user.SID } else { Disable-LocalUser -SID $user.SID }
    }
}

# --- Defender, SMB, event log, backup ---------------------------------------

# Set-RealtimeProtection turns Microsoft Defender real-time protection on or
# off and waits until Defender reports it; it skips the case when Defender
# cannot do so here (not running, or in passive mode).
function Set-RealtimeProtection([bool]$Enabled) {
    $pref = $null
    if (Get-Command Get-MpPreference -ErrorAction SilentlyContinue) { $pref = Get-MpPreference -ErrorAction SilentlyContinue }
    if (-not $pref) { Skip-Case "Microsoft Defender is not running" }
    Add-Undo @{ Kind = 'defender'; DisableRealtimeMonitoring = [bool]$pref.DisableRealtimeMonitoring }
    Set-MpPreference -DisableRealtimeMonitoring (-not $Enabled)
    for ($i = 0; $i -lt 30; $i++) {
        $status = Get-MpComputerStatus -ErrorAction SilentlyContinue
        if ($status -and $status.RealTimeProtectionEnabled -eq $Enabled -and (-not $Enabled -or $status.AntivirusEnabled)) { return }
        Start-Sleep -Seconds 1
    }
    Skip-Case "Defender does not report real-time protection as $Enabled (AntivirusEnabled = $($status.AntivirusEnabled), RealTimeProtectionEnabled = $($status.RealTimeProtectionEnabled))"
}

# Set-SmbServer sets SMB server settings (EnableSMB1Protocol, RequireSecuritySignature, ...).
function Set-SmbServer([hashtable]$Settings) {
    $config = Get-SmbServerConfiguration
    $old = @{}
    foreach ($name in $Settings.Keys) { $old[$name] = $config.$name }
    Add-Undo @{ Kind = 'smb'; Settings = $old }
    Set-SmbServerConfiguration @Settings -Force -Confirm:$false
}

function Get-EventLogSize([string]$Log) {
    $line = wevtutil gl $Log | Select-String -Pattern '^\s*maxSize:\s*(\d+)'
    if (-not $line) { throw "wevtutil gl $Log printed no maxSize" }
    return [int64]$line.Matches[0].Groups[1].Value
}

# Set-EventLogSize sets the maximum size of an event log, in bytes (a multiple of 64 KB).
function Set-EventLogSize([string]$Log, [int64]$Bytes) {
    $old = Get-EventLogSize $Log
    Add-Undo @{ Kind = 'eventlog'; Log = $Log; Bytes = $old }
    wevtutil sl $Log /ms:$Bytes
    if ($LASTEXITCODE -ne 0) { throw "wevtutil sl $Log /ms:$Bytes failed with exit code $LASTEXITCODE" }
}

# Install-WindowsServerBackup adds the Windows Server Backup feature, or skips
# the case where Windows has no such feature. The feature stays installed:
# removing it needs a restart.
function Install-WindowsServerBackup {
    if (Get-Command Get-WBPolicy -ErrorAction SilentlyContinue) { return }
    if (-not (Get-Command Install-WindowsFeature -ErrorAction SilentlyContinue)) {
        Skip-Case "Windows Server Backup is a Windows Server feature"
    }
    $result = Install-WindowsFeature -Name Windows-Server-Backup
    if (-not $result.Success) { Skip-Case "Windows Server Backup could not be installed" }
    Import-Module WindowsServerBackup
}

# Set-BackupPolicy installs Windows Server Backup and replaces its (empty)
# policy with the given one; restore removes it again. Without a policy it
# only makes sure none is set.
function Set-BackupPolicy($Policy) {
    Install-WindowsServerBackup
    if (Get-WBPolicy -ErrorAction SilentlyContinue) { Skip-Case "a backup policy is already configured" }
    if ($null -eq $Policy) { return }
    Add-Undo @{ Kind = 'backup' }
    Set-WBPolicy -Policy $Policy -Force
}

# --- Restore and run --------------------------------------------------------

function Restore-Entry([hashtable]$e) {
    switch ($e.Kind) {
        'registry' {
            if ($e.Created) {
                Remove-Item -LiteralPath $e.Created -Recurse -Force -ErrorAction SilentlyContinue
            } elseif ($e.Exists) {
                New-ItemProperty -LiteralPath $e.Path -Name $e.Name -Value $e.Value -PropertyType $e.Type -Force | Out-Null
            } else {
                Remove-ItemProperty -LiteralPath $e.Path -Name $e.Name -ErrorAction SilentlyContinue
            }
        }
        'policy' {
            if ($e.Settings.Count -gt 0) { Write-SecurityPolicy 'System Access' 'SECURITYPOLICY' $e.Settings }
        }
        'right' { Write-SecurityPolicy 'Privilege Rights' 'USER_RIGHTS' @{ $e.Right = $e.Value } }
        'audit' { Write-AuditPolicy $e.Subcategory $e.Success $e.Failure }
        'service' { Set-Service -Name $e.Name -StartupType $e.StartupType }
        'firewall' { Set-NetFirewallProfile -Name $e.Name -PolicyStore PersistentStore -Enabled $e.Enabled }
        'account' {
            $user = Get-BuiltinAccount $e.Rid
            if ($user.Name -ne $e.Name) { Rename-LocalUser -SID $user.SID -NewName $e.Name }
            if ($e.Enabled) { Enable-LocalUser -SID $user.SID } else { Disable-LocalUser -SID $user.SID }
        }
        'defender' { Set-MpPreference -DisableRealtimeMonitoring $e.DisableRealtimeMonitoring }
        'smb' {
            $settings = $e.Settings
            Set-SmbServerConfiguration @settings -Force -Confirm:$false
        }
        'eventlog' {
            wevtutil sl $e.Log /ms:$($e.Bytes)
            if ($LASTEXITCODE -ne 0) { throw "wevtutil sl $($e.Log) failed with exit code $LASTEXITCODE" }
        }
        'backup' { if (Get-WBPolicy -ErrorAction SilentlyContinue) { Remove-WBPolicy -All -Force } }
        default { throw "unknown undo entry $($e.Kind)" }
    }
}

$principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "the Windows cases need an elevated session"
}

if ($Restore) {
    if (-not (Test-Path -LiteralPath $Undo)) { exit 0 }
    $entries = @(Import-Clixml -LiteralPath $Undo)
    [array]::Reverse($entries)
    $failed = 0
    foreach ($entry in $entries) {
        try {
            Restore-Entry $entry
        } catch {
            [Console]::Error.WriteLine("restoring $($entry.Kind) $($entry.Path)$($entry.Name)$($entry.Subcategory): $_")
            $failed++
        }
    }
    if ($failed -gt 0) { exit 1 }
    exit 0
}

if (-not $Case) { throw "give -Case <setup.ps1> or -Restore" }
. $Case
exit 0
