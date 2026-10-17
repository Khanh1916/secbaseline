$audit_output = auditpol /get /subcategory:"Special Logon" 2>$null

if (-not $audit_output) {
    Write-Output "Special Logon auditing setting is not Success."
    exit 1
}

$audit_setting = ($audit_output | Select-String "Special Logon").ToString().Split()[-1]

if ($audit_setting -ne "Success") {
    Write-Output "Special Logon auditing setting is not Success."
    exit 1
}

Write-Output "Special Logon auditing setting is Success."
exit 0