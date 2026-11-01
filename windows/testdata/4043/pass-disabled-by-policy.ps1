# LLMNR is turned off by policy.
$dns = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient'
Set-RegistryValue $dns EnableMulticast 0
