$lockout_output = net accounts | Select-String "Lockout duration"

if (-not $lockout_output) {
    Write-Output "Lockout duration is less than 15 minutes or not configured."
    exit 1
}

$lockout_value = ($lockout_output -split ':')[1].Trim()

if ([int]$lockout_value -lt 15) {
    Write-Output "Lockout duration is less than 15 minutes or not configured."
    exit 1
}

Write-Output "Lockout duration=15 minutes or greater is configured."
exit 0
