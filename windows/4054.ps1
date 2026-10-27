# Ensure the machine inactivity limit is 900 seconds or less
function Get-RegValue([string]$Path, [string]$Name) {
    $item = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $item) { return $null }
    return $item.$Name
}

$seconds = Get-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "InactivityTimeoutSecs"
if ($null -eq $seconds -or $seconds -lt 1 -or $seconds -gt 900) {
    Write-Output "FAIL: Machine inactivity limit is not set between 1 and 900 seconds (InactivityTimeoutSecs = $seconds)"
    exit 1
}

Write-Output "PASS: Machine inactivity limit is $seconds seconds"
exit 0
