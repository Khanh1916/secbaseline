# The Security log holds 196608 KB, without a policy.
$policy = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security'
Set-EventLogSize Security 201326592
Remove-RegistryValue $policy MaxSize
