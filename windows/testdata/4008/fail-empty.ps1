# Empty title and text, the Windows default.
$system = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
Set-RegistryValue $system legalnoticecaption '' -Type String
Set-RegistryValue $system legalnoticetext '' -Type String
