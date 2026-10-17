$audit_output = auditpol /get /subcategory:"Sensitive Privilege Use" 2>$null

if (-not $audit_output) {
    Write-Output "FAIL: Sensitive Privilege Use auditing setting is not Success"
    exit 1
}

$audit_setting = ($audit_output | Select-String "Sensitive Privilege Use").ToString().Split()[-1]

if ($audit_setting -ne "Success") {
    Write-Output "FAIL: Sensitive Privilege Use auditing setting is not Success"
    exit 1
}

Write-Output "PASS: Sensitive Privilege Use auditing setting is Success"
exit 0