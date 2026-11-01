# Remote Desktop is on locally without NLA, but policy turns it off.
$ts = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server'
$rdp = "$ts\WinStations\RDP-Tcp"
$policy = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'
Set-RegistryValue $ts fDenyTSConnections 0
Set-RegistryValue $rdp UserAuthentication 0
Set-RegistryValue $policy fDenyTSConnections 1
Remove-RegistryValue $policy UserAuthentication
