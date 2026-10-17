$audit_output = auditpol /get /subcategory:"Directory Service Access" 2>$null

if (-not $audit_output) {
    Write-Output "Directory Service Access auditing setting is not Success."
    exit 1
}

$audit_setting = ($audit_output | Select-String "Directory Service Access").ToString().Split()[-1]

if ($audit_setting -ne "Success") {
    Write-Output "Directory Service Access auditing setting is not Success."
    exit 1
}

Write-Output "Directory Service Access auditing setting is Success."
exit 0