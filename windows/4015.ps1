$audit_output = auditpol /get /subcategory:"Process Creation" 2>$null

if (-not $audit_output) {
    Write-Output "FAIL: Process Creation auditing setting is not Success"
    exit 1
}

$audit_setting = ($audit_output | Select-String "Process Creation").ToString().Split()[-1]

if ($audit_setting -ne "Success") {
    Write-Output "FAIL: Process Creation auditing setting is not Success"
    exit 1
}

Write-Output "PASS: Process Creation auditing setting is Success"
exit 0