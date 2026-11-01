# Ensure 'Act as part of the operating system' is assigned to No One
# Local security policy, [Privilege Rights] section. secedit needs an elevated session.
function Get-UserRights {
    $cfg = Join-Path $env:TEMP ("secbaseline-" + [guid]::NewGuid().ToString() + ".inf")
    try {
        secedit /export /cfg $cfg /areas USER_RIGHTS /quiet *> $null
        if (-not (Test-Path $cfg)) { return $null }
        $rights = @{}
        $section = $null
        foreach ($line in Get-Content $cfg) {
            if ($line -match '^\s*\[(.+)\]\s*$') {
                $section = $Matches[1]
            } elseif ($section -eq 'Privilege Rights' -and $line -match '^\s*(\w+)\s*=\s*(.*?)\s*$') {
                $rights[$Matches[1]] = $Matches[2]
            }
        }
        if ($rights.Count -eq 0) { return $null }
        return $rights
    } finally {
        Remove-Item $cfg -Force -ErrorAction SilentlyContinue
    }
}

$rights = Get-UserRights
if ($null -eq $rights) {
    Write-Output "FAIL: Could not read the local security policy; run from an elevated session"
    exit 1
}

# A right that no account holds is not listed at all.
$holders = @($rights["SeTcbPrivilege"] -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
if ($holders.Count -gt 0) {
    Write-Output "FAIL: 'Act as part of the operating system' (SeTcbPrivilege) is assigned to $($holders -join ', ')"
    exit 1
}

Write-Output "PASS: 'Act as part of the operating system' (SeTcbPrivilege) is assigned to No One"
exit 0
