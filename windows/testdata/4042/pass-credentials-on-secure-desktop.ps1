# Prompt for credentials on the secure desktop (1), stricter than consent.
$system = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
Set-RegistryValue $system ConsentPromptBehaviorAdmin 1
Set-RegistryValue $system PromptOnSecureDesktop 1
