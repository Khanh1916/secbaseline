# The Public profile is disabled locally, but Group Policy enables it.
Set-FirewallProfile Domain True
Set-FirewallProfile Private True
Set-FirewallProfile Public False
Set-FirewallPolicy Public True
Wait-FirewallProfile Domain $true
Wait-FirewallProfile Private $true
Wait-FirewallProfile Public $true
# Get-NetFirewallProfile without -PolicyStore reads the local store, which still says disabled.
if ([string](Get-NetFirewallProfile -Name Public).Enabled -ne 'False') { throw 'the local store should still disable the Public profile' }
