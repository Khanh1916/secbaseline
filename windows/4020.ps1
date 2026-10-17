$audit_output = auditpol /get /subcategory:"Other Logon/Logoff Events" 2>$null

if (-not $audit_output) {
    Write-Output "Other Logon/Logoff Events auditing setting is not Success."
    exit 1
}

$audit_setting = ($audit_output | Select-String "Other Logon/Logoff Events").ToString().Split()[-1]

if ($audit_setting -ne "Success") {
    Write-Output "Other Logon/Logoff Events auditing setting is not Success."
    exit 1
}

Write-Output "Other Logon/Logoff Events auditing setting is Success."
exit 0