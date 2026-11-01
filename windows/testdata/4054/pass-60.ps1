# The machine locks after 60 seconds of inactivity.
$system = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
Set-RegistryValue $system InactivityTimeoutSecs 60
