# Every profile is enabled locally, but Group Policy disables the Public profile.
Set-FirewallProfile Domain True
Set-FirewallProfile Private True
Set-FirewallProfile Public True
Set-FirewallPolicy Public False
Wait-FirewallProfile Domain $true
Wait-FirewallProfile Private $true
Wait-FirewallProfile Public $false
# Get-NetFirewallProfile without -PolicyStore reads the local store, which still says enabled.
if ([string](Get-NetFirewallProfile -Name Public).Enabled -ne 'True') { throw 'the local store should still enable the Public profile' }
