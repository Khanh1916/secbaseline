# Prompt for consent on the secure desktop (2).
$system = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
Set-RegistryValue $system ConsentPromptBehaviorAdmin 2
Set-RegistryValue $system PromptOnSecureDesktop 1
