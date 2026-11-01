# Every profile is enabled.
$policy = 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall'
Set-FirewallProfile Domain True
Set-FirewallProfile Private True
Set-FirewallProfile Public True
Remove-RegistryValue "$policy\DomainProfile" EnableFirewall
Remove-RegistryValue "$policy\PrivateProfile" EnableFirewall
Remove-RegistryValue "$policy\PublicProfile" EnableFirewall
Wait-FirewallProfile Domain $true
Wait-FirewallProfile Private $true
Wait-FirewallProfile Public $true
