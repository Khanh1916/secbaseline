# No LLMNR policy: LLMNR is on.
$dns = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient'
Remove-RegistryValue $dns EnableMulticast
