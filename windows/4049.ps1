# Ensure the Remote Registry service is disabled
$service = Get-Service -Name RemoteRegistry -ErrorAction SilentlyContinue
if (-not $service) {
    Write-Output "PASS: Remote Registry service is not installed"
    exit 0
}

if ($service.StartType -ne "Disabled") {
    Write-Output "FAIL: Remote Registry service start type is $($service.StartType)"
    exit 1
}

Write-Output "PASS: Remote Registry service is disabled"
exit 0
