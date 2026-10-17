$audit_output = auditpol /get /subcategory:"Audit Policy Change" 2>$null

if (-not $audit_output) {
    Write-Output "Audit Policy Change auditing setting is not Success."
    exit 1
}

$audit_setting = ($audit_output | Select-String "Audit Policy Change").ToString().Split()[-1]

if ($audit_setting -ne "Success") {
    Write-Output "Audit Policy Change auditing setting is not Success."
    exit 1
}

Write-Output "Audit Policy Change auditing setting is Success."
exit 0