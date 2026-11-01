# NoDriveTypeAutoRun is not set.
$explorer = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'
Remove-RegistryValue $explorer NoDriveTypeAutoRun
