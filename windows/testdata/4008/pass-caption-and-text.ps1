# A legal notice title and text.
$system = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
Set-RegistryValue $system legalnoticecaption 'Authorized use only' -Type String
Set-RegistryValue $system legalnoticetext 'This system is for authorized use only. Activity is monitored.' -Type String
