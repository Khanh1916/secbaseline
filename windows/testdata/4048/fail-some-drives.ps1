# AutoPlay is turned off for some drive types only (0x91).
$explorer = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'
Set-RegistryValue $explorer NoDriveTypeAutoRun 0x91
