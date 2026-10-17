$audit_output = auditpol /get /subcategory:"Security Group Management" 2>$null

if (-not $audit_output) {
    Write-Output "Security Group Management auditing setting is not Success."
    exit 1
}

$audit_setting = ($audit_output | Select-String "Security Group Management").ToString().Split()[-1]

if ($audit_setting -ne "Success") {
    Write-Output "Security Group Management auditing setting is not Success."
    exit 1
}

Write-Output "Security Group Management auditing setting is Success."
exit 0