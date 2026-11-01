# A title, and a text stored as a multi-string value, one line per string.
$system = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
Set-RegistryValue $system legalnoticecaption 'Authorized use only' -Type String
Set-RegistryValue $system legalnoticetext @('This system is for authorized use only.', 'Activity is monitored.') -Type MultiString
