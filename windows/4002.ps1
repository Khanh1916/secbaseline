$complexity_output = net accounts | Select-String "Password complexity requirements"

if (-not $complexity_output) {
    Write-Output "FAIL: Password complexity requirements is set to No or not configured"
    exit 1
}

$complexity_value = ($complexity_output -split ':')[1].Trim()

if ($complexity_value -ne "Yes") {
    Write-Output "FAIL: Password complexity requirements is set to No or not configured"
    exit 1
}

Write-Output "PASS: Password complexity requirements is set to Yes"
exit 0
