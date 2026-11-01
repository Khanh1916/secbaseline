# A title, and no text value at all.
$system = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
Set-RegistryValue $system legalnoticecaption 'Authorized use only' -Type String
Remove-RegistryValue $system legalnoticetext
