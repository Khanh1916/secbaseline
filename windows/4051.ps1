# Ensure the Security event log is at least 196608 KB
function Get-RegValue([string]$Path, [string]$Name) {
    $item = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $item) { return $null }
    return $item.$Name
}

$minimumKB = 196608
$sizeKB = $null

# Group Policy setting, in KB.
$policyKB = Get-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security" "MaxSize"
if ($null -ne $policyKB) {
    $sizeKB = [int64]$policyKB
} else {
    # Effective log configuration, in bytes; readable without elevation.
    $line = wevtutil gl Security 2>$null | Select-String -Pattern "^\s*maxSize:\s*(\d+)"
    if ($line) {
        $sizeKB = [int64]$line.Matches[0].Groups[1].Value / 1024
    }
}

if ($null -eq $sizeKB) {
    Write-Output "FAIL: Could not read the Security event log size"
    exit 1
}

if ($sizeKB -lt $minimumKB) {
    Write-Output "FAIL: Security event log maximum size is $sizeKB KB (minimum $minimumKB KB)"
    exit 1
}

Write-Output "PASS: Security event log maximum size is $sizeKB KB"
exit 0
