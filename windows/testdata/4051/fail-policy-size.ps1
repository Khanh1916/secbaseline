# Policy sets 32768 KB, over a 196608 KB log size.
$policy = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security'
Set-EventLogSize Security 201326592
Set-RegistryValue $policy MaxSize 32768
