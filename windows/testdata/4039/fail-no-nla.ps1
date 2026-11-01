# Remote Desktop is on without NLA.
$ts = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server'
$rdp = "$ts\WinStations\RDP-Tcp"
$policy = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'
Set-RegistryValue $ts fDenyTSConnections 0
Set-RegistryValue $rdp UserAuthentication 0
Remove-RegistryValue $policy fDenyTSConnections
Remove-RegistryValue $policy UserAuthentication
