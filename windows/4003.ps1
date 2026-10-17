$history_output = net accounts | Select-String "Length of password history" -ErrorAction SilentlyContinue

if (-not $history_output) {
    Write-Output "FAIL: Length of password history is less than 24 or not configured"
    exit 1
}

$history_value = ($history_output -split ':')[1].Trim()

if (-not [int]::TryParse($history_value, [ref]$null) -or [int]$history_value -lt 24) {
    Write-Output "FAIL: Length of password history is less than 24 or not configured"
    exit 1
}

Write-Output "PASS: Length of password history=24 or greater is configured"
exit 0
