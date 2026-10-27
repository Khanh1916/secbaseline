# Ensure the built-in Administrator account is renamed
$admin = Get-LocalUser -ErrorAction SilentlyContinue | Where-Object { $_.SID.Value -like "S-1-5-*-500" }
if (-not $admin) {
    Write-Output "FAIL: Could not find the built-in Administrator account (SID ending in -500)"
    exit 1
}

if ($admin.Name -eq "Administrator") {
    Write-Output "FAIL: The built-in Administrator account still uses its default name"
    exit 1
}

Write-Output "PASS: The built-in Administrator account is renamed"
exit 0
