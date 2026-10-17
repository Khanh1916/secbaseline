$guest_output = net user Guest 2>$null

if (-not $guest_output) {
    Write-Output "FAIL: Guest account is enabled or not found"
    exit 1
}

$enabled_status = ($guest_output | Select-String "Account active").ToString().Split()[-1]

if ($enabled_status -ne "No") {
    Write-Output "FAIL: Guest account is enabled or not found"
    exit 1
}

Write-Output "PASS: Guest account is disabled (Enabled=False)"
exit 0
