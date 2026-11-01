# The Public profile is disabled locally, but policy enables it.
$policy = 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall'
Set-FirewallProfile Domain True
Set-FirewallProfile Private True
Set-FirewallProfile Public False
Remove-RegistryValue "$policy\DomainProfile" EnableFirewall
Remove-RegistryValue "$policy\PrivateProfile" EnableFirewall
Set-RegistryValue "$policy\PublicProfile" EnableFirewall 1
Wait-FirewallProfile Domain $true
Wait-FirewallProfile Private $true
Wait-FirewallProfile Public $true
