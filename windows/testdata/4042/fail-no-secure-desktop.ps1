# Prompt for consent (2), but not on the secure desktop.
$system = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
Set-RegistryValue $system ConsentPromptBehaviorAdmin 2
Set-RegistryValue $system PromptOnSecureDesktop 0
