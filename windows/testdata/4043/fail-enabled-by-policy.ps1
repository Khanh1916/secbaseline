# LLMNR is turned on by policy.
$dns = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient'
Set-RegistryValue $dns EnableMulticast 1
