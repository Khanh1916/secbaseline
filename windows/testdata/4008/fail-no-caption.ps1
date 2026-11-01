# A text without a title.
$system = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
Set-RegistryValue $system legalnoticecaption '' -Type String
Set-RegistryValue $system legalnoticetext 'This system is for authorized use only.' -Type String
