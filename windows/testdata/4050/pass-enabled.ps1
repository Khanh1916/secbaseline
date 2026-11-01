# Script block logging is turned on by policy.
$logging = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'
Set-RegistryValue $logging EnableScriptBlockLogging 1
