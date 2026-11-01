# Prompt for consent (2); PromptOnSecureDesktop is unset and defaults to on.
$system = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
Set-RegistryValue $system ConsentPromptBehaviorAdmin 2
Remove-RegistryValue $system PromptOnSecureDesktop
