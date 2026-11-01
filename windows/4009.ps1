# Ensure the Guest account is disabled
# The built-in Guest account is found by its SID, which ends in -501, so it is
# found when renamed and in every display language.
$guest = Get-LocalUser -ErrorAction SilentlyContinue | Where-Object { $_.SID.Value -like "S-1-5-21-*-501" }
if (-not $guest) {
    Write-Output "FAIL: Could not find the built-in Guest account (SID ending in -501)"
    exit 1
}

if ($guest.Enabled) {
    Write-Output "FAIL: The built-in Guest account is enabled"
    exit 1
}

Write-Output "PASS: The built-in Guest account is disabled"
exit 0
