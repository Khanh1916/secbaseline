# The machine locks after 900 seconds of inactivity.
$system = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
Set-RegistryValue $system InactivityTimeoutSecs 900
