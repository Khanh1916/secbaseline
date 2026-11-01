# Script block logging is turned off by policy.
$logging = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'
Set-RegistryValue $logging EnableScriptBlockLogging 0
