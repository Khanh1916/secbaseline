# InactivityTimeoutSecs is not set.
$system = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
Remove-RegistryValue $system InactivityTimeoutSecs
