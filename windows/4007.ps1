$temp_file = "$env:TEMP\secpol.cfg"

secedit /export /cfg $temp_file *>$null
$privilege_output = Get-Content $temp_file -ErrorAction SilentlyContinue | Select-String "SeTcbPrivilege"
Remove-Item $temp_file -Force -ErrorAction SilentlyContinue

if (-not $privilege_output) {
    Write-Output "SeTcbPrivilege is not definded or not found."
    exit 1
}

$privilege_value = ($privilege_output -split '=')[1].Trim()

if ($privilege_value) {
    Write-Output "SeTcbPrivilege is assigned to users or groups (not No One)."
    exit 1
}

Write-Output "SeTcbPrivilege is assigned to No One."
exit 0
