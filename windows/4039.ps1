# Ensure Remote Desktop requires Network Level Authentication
function Get-RegValue([string]$Path, [string]$Name) {
    $item = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $item) { return $null }
    return $item.$Name
}

# Group Policy values, where set, take precedence over the local ones.
$policyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
$deny = Get-RegValue $policyPath "fDenyTSConnections"
if ($null -eq $deny) {
    $deny = Get-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" "fDenyTSConnections"
}
if ($deny -eq 1) {
    Write-Output "PASS: Remote Desktop is disabled"
    exit 0
}

$nla = Get-RegValue $policyPath "UserAuthentication"
if ($null -eq $nla) {
    $nla = Get-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" "UserAuthentication"
}
if ($nla -eq 1) {
    Write-Output "PASS: Remote Desktop requires Network Level Authentication"
    exit 0
}

Write-Output "FAIL: Remote Desktop is enabled without Network Level Authentication"
exit 1
