# Every profile is enabled locally, but policy disables the Public profile.
$policy = 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall'
Set-FirewallProfile Domain True
Set-FirewallProfile Private True
Set-FirewallProfile Public True
Remove-RegistryValue "$policy\DomainProfile" EnableFirewall
Remove-RegistryValue "$policy\PrivateProfile" EnableFirewall
Set-RegistryValue "$policy\PublicProfile" EnableFirewall 0
Wait-FirewallProfile Domain $true
Wait-FirewallProfile Private $true
Wait-FirewallProfile Public $false
