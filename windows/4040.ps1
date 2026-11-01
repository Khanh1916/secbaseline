# Ensure Windows Firewall is enabled for all profiles
# The active store holds the settings in effect: local ones merged with Group
# Policy, which wins where it sets a profile.
$profiles = Get-NetFirewallProfile -PolicyStore ActiveStore -ErrorAction SilentlyContinue
if (-not $profiles) {
    Write-Output "FAIL: Could not read Windows Firewall profiles"
    exit 1
}

$disabled = @($profiles | Where-Object { [string]$_.Enabled -ne "True" } | ForEach-Object { $_.Name })
if ($disabled.Count -gt 0) {
    Write-Output "FAIL: Windows Firewall is disabled for: $($disabled -join ', ')"
    exit 1
}

Write-Output "PASS: Windows Firewall is enabled for the Domain, Private and Public profiles"
exit 0
