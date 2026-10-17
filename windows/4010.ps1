$audit_output = auditpol /get /subcategory:"Application Group Management" 2>$null

if (-not $audit_output) {
    Write-Output "Application Group Management auditing setting is not Success."
    exit 1
}

$audit_setting = ($audit_output | Select-String "Application Group Management").ToString().Split()[-1]

if ($audit_setting -ne "Success") {
    Write-Output "Application Group Management auditing setting is not Success."
    exit 1
}

Write-Output "Application Group Management auditing setting is Success."
exit 0