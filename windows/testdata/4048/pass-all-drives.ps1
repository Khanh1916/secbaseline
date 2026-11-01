# AutoPlay is turned off for all drives (255).
$explorer = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'
Set-RegistryValue $explorer NoDriveTypeAutoRun 255
