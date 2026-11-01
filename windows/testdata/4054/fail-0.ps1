# InactivityTimeoutSecs = 0: the machine never locks.
$system = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
Set-RegistryValue $system InactivityTimeoutSecs 0
