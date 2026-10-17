$reversible_output = net accounts | Select-String "reversible encryption"

if (-not $reversible_output) {
    Write-Output "Reversible encryption is set to Yes or not configured."
    exit 1
}

$reversible_value = ($reversible_output -split ':')[1].Trim()

if ($reversible_value -ne "No") {
    Write-Output "Reversible encryption is set to Yes or not configured."
    exit 1
}

Write-Output "Reversible encryption is set to No."
exit 0
