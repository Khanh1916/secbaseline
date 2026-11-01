# A title without a text.
$system = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
Set-RegistryValue $system legalnoticecaption 'Authorized use only' -Type String
Set-RegistryValue $system legalnoticetext '' -Type String
