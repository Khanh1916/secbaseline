$audit_output = auditpol /get /subcategory:"Account Lockout" 2>$null

if (-not $audit_output) {
    Write-Output "Account Lockout auditing setting is not Success."
    exit 1
}

$audit_setting = ($audit_output | Select-String "Account Lockout").ToString().Split()[-1]

if ($audit_setting -ne "Success") {
    Write-Output "Account Lockout auditing setting is not Success."
    exit 1
}

Write-Output "Account Lockout auditing setting is Success."
exit 0