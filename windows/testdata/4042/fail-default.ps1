# The Windows default: prompt for consent for non-Windows binaries (5).
$system = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
Set-RegistryValue $system ConsentPromptBehaviorAdmin 5
Set-RegistryValue $system PromptOnSecureDesktop 1
