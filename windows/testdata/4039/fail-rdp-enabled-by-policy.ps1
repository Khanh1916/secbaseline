# Remote Desktop is off locally, but policy turns it on, without NLA.
$ts = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server'
$rdp = "$ts\WinStations\RDP-Tcp"
$policy = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'
Set-RegistryValue $ts fDenyTSConnections 1
Set-RegistryValue $rdp UserAuthentication 0
Set-RegistryValue $policy fDenyTSConnections 0
Remove-RegistryValue $policy UserAuthentication
