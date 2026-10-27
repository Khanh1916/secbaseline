# Ensure LLMNR (multicast name resolution) is disabled
function Get-RegValue([string]$Path, [string]$Name) {
    $item = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $item) { return $null }
    return $item.$Name
}

$multicast = Get-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" "EnableMulticast"
if ($multicast -ne 0) {
    Write-Output "FAIL: LLMNR is not disabled by policy (EnableMulticast is not 0)"
    exit 1
}

Write-Output "PASS: LLMNR is disabled"
exit 0
