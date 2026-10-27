# Ensure 'Distribution Group Management' auditing includes Success
$name = "Distribution Group Management"
$subcategory = "{0CCE9238-69AE-11D9-BED3-505054503030}"

# auditpol /backup lists subcategories by GUID with a numeric setting
# (1 = Success, 2 = Failure, 3 = both) in every display language. It needs an
# elevated session.
$file = Join-Path $env:TEMP ("secbaseline-" + [guid]::NewGuid().ToString() + ".csv")
$setting = $null
try {
    auditpol /backup /file:$file *> $null
    # Without the privilege auditpol fails but still leaves an empty file.
    if ($LASTEXITCODE -eq 0 -and (Test-Path $file)) {
        $setting = 0
        $row = Import-Csv $file -Header Machine, Target, Subcategory, Guid, Inclusion, Exclusion, Value |
            Where-Object { $_.Guid -eq $subcategory } | Select-Object -First 1
        if ($row) { $setting = [int]$row.Value }
    }
} finally {
    Remove-Item $file -Force -ErrorAction SilentlyContinue
}

if ($null -eq $setting) {
    Write-Output "FAIL: Could not read the audit policy; run from an elevated session"
    exit 1
}

$labels = @{ 0 = "No Auditing"; 1 = "Success"; 2 = "Failure"; 3 = "Success and Failure" }
if (($setting -band 1) -eq 0) {
    Write-Output "FAIL: $name auditing is set to $($labels[$setting]), which does not include Success"
    exit 1
}

Write-Output "PASS: $name auditing is set to $($labels[$setting])"
exit 0
