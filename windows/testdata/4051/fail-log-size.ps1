# The Security log holds 20480 KB, without a policy.
$policy = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security'
Set-EventLogSize Security 20971520
Remove-RegistryValue $policy MaxSize
