$audit_output = auditpol /get /subcategory:"Logoff" 2>$null

if (-not $audit_output) {
    Write-Output "Logoff auditing setting is not Success."
    exit 1
}

$audit_setting = ($audit_output | Select-String "Logoff").ToString().Split()[-1]

if ($audit_setting -ne "Success") {
    Write-Output "Logoff auditing setting is not Success."
    exit 1
}

Write-Output "Logoff auditing setting is Success."
exit 0