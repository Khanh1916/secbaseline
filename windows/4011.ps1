$audit_output = auditpol /get /subcategory:"Computer Account Management" 2>$null

if (-not $audit_output) {
    Write-Output "Computer Account Management auditing setting is not Success."
    exit 1
}

$audit_setting = ($audit_output | Select-String "Computer Account Management").ToString().Split()[-1]

if ($audit_setting -ne "Success") {
    Write-Output "Computer Account Management auditing setting is not Success."
    exit 1
}

Write-Output "Computer Account Management auditing setting is Success."
exit 0