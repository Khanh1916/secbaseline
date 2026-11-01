# Policy sets 196608 KB, over a 20480 KB log size.
$policy = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security'
Set-EventLogSize Security 20971520
Set-RegistryValue $policy MaxSize 196608
