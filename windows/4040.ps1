# Ensure Windows Firewall is enabled for all profiles
$profiles = Get-NetFirewallProfile -ErrorAction SilentlyContinue
if (-not $profiles) {
    Write-Output "FAIL: Could not read Windows Firewall profiles"
    exit 1
}

$disabled = @($profiles | Where-Object { -not $_.Enabled } | ForEach-Object { $_.Name })
if ($disabled.Count -gt 0) {
    Write-Output "FAIL: Windows Firewall is disabled for: $($disabled -join ', ')"
    exit 1
}

Write-Output "PASS: Windows Firewall is enabled for the Domain, Private and Public profiles"
exit 0
