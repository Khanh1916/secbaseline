# Ensure Remote Desktop requires Network Level Authentication
function Get-RegValue([string]$Path, [string]$Name) {
    $item = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $item) { return $null }
    return $item.$Name
}

$deny = Get-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" "fDenyTSConnections"
if ($deny -eq 1) {
    Write-Output "PASS: Remote Desktop is disabled"
    exit 0
}

$policy = Get-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "UserAuthentication"
$local = Get-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" "UserAuthentication"
if ($policy -eq 1 -or ($null -eq $policy -and $local -eq 1)) {
    Write-Output "PASS: Remote Desktop requires Network Level Authentication"
    exit 0
}

Write-Output "FAIL: Remote Desktop is enabled without Network Level Authentication"
exit 1
