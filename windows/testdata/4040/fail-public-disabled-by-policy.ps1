# Every profile is enabled locally, but Group Policy disables the Public profile.
$policy = 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall'
Set-FirewallProfile Domain True
Set-FirewallProfile Private True
Set-FirewallProfile Public True
Remove-RegistryValue "$policy\DomainProfile" EnableFirewall
Remove-RegistryValue "$policy\PrivateProfile" EnableFirewall
Set-FirewallPolicy Public 0
Wait-FirewallProfile Domain $true
Wait-FirewallProfile Private $true
Wait-FirewallProfile Public $false
# Get-NetFirewallProfile without -PolicyStore reads the local store, which still says enabled.
if ([string](Get-NetFirewallProfile -Name Public).Enabled -ne 'True') { throw 'the local store should still enable the Public profile' }
