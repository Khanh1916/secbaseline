# Elevate without prompting (0).
$system = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
Set-RegistryValue $system ConsentPromptBehaviorAdmin 0
Set-RegistryValue $system PromptOnSecureDesktop 1
