$threshold_output = net accounts | Select-String "Lockout threshold"

if (-not $threshold_output) {
    Write-Output "Lockout threshold is not within range 1-5 or not configured."
    exit 1
}

$threshold_value = ($threshold_output -split ':')[1].Trim()

if (([int]$threshold_value -lt 1) -or ([int]$threshold_value -gt 5)) {
    Write-Output "Lockout threshold is not within range 1-5 or not configured."
    exit 1
}

Write-Output "Lockout threshold is within range 1-5."
exit 0
