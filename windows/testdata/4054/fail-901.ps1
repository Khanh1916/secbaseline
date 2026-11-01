# The machine locks after 901 seconds of inactivity.
$system = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
Set-RegistryValue $system InactivityTimeoutSecs 901
