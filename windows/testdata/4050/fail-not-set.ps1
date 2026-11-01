# No script block logging policy.
$logging = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'
Remove-RegistryValue $logging EnableScriptBlockLogging
