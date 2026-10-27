# Ensure AutoPlay is turned off for all drives
function Get-RegValue([string]$Path, [string]$Name) {
    $item = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $item) { return $null }
    return $item.$Name
}

$value = Get-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoDriveTypeAutoRun"
if ($value -ne 255) {
    Write-Output "FAIL: AutoPlay is not turned off for all drives (NoDriveTypeAutoRun = $value, expected 255)"
    exit 1
}

Write-Output "PASS: AutoPlay is turned off for all drives"
exit 0
