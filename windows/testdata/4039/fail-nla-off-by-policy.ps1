# Remote Desktop is on; NLA is required locally, but policy turns it off.
$ts = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server'
$rdp = "$ts\WinStations\RDP-Tcp"
$policy = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'
Set-RegistryValue $ts fDenyTSConnections 0
Set-RegistryValue $rdp UserAuthentication 1
Remove-RegistryValue $policy fDenyTSConnections
Set-RegistryValue $policy UserAuthentication 0
