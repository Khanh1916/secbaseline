$minlen_output = net accounts | Select-String "Minimum password length"

if (-not $minlen_output) {
    Write-Output "FAIL: Minimum password length is not configured or less than 8"
    exit 1
}

$minlen_value = ($minlen_output -split ':')[1].Trim()

if ([int]$minlen_value -lt 8) {
    Write-Output "FAIL: Minimum password length is not configured or less than 8"
    exit 1
}

Write-Output "PASS: Minimum password length = 8 or greater is configured"
exit 0
