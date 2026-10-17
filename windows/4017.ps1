$audit_output = auditpol /get /subcategory:"Directory Service Changes" 2>$null

if (-not $audit_output) {
    Write-Output "Directory Service Changes auditing setting is not Success."
    exit 1
}

$audit_setting = ($audit_output | Select-String "Directory Service Changes").ToString().Split()[-1]

if ($audit_setting -ne "Success") {
    Write-Output "Directory Service Changes auditing setting is not Success."
    exit 1
}

Write-Output "Directory Service Changes auditing setting is Success."
exit 0