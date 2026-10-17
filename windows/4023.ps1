$audit_output = auditpol /get /subcategory:"Authentication Policy Change" 2>$null

if (-not $audit_output) {
    Write-Output "Authentication Policy Change auditing setting is not Success."
    exit 1
}

$audit_setting = ($audit_output | Select-String "Authentication Policy Change").ToString().Split()[-1]

if ($audit_setting -ne "Success") {
    Write-Output "Authentication Policy Change auditing setting is not Success."
    exit 1
}

Write-Output "Authentication Policy Change auditing setting is Success."
exit 0