# The Public profile is disabled locally, but Group Policy enables it.
$policy = 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall'
Set-FirewallProfile Domain True
Set-FirewallProfile Private True
Set-FirewallProfile Public False
Remove-RegistryValue "$policy\DomainProfile" EnableFirewall
Remove-RegistryValue "$policy\PrivateProfile" EnableFirewall
Set-FirewallPolicy Public 1
Wait-FirewallProfile Domain $true
Wait-FirewallProfile Private $true
Wait-FirewallProfile Public $true
# Get-NetFirewallProfile without -PolicyStore reads the local store, which still says disabled.
if ([string](Get-NetFirewallProfile -Name Public).Enabled -ne 'False') { throw 'the local store should still disable the Public profile' }
