$av_status = Get-MpComputerStatus -ErrorAction SilentlyContinue | Select-Object AntivirusEnabled, RealTimeProtectionEnabled

if (-not $av_status) {
    Write-Output "Anti-virus protection is not enabled (AntivirusEnabled or RealTimeProtectionEnabled is False)."
    exit 1
}

$antivirus_enabled = $av_status.AntivirusEnabled
$realtime_enabled = $av_status.RealTimeProtectionEnabled

if (($antivirus_enabled -ne $true) -or ($realtime_enabled -ne $true)) {
    Write-Output "Anti-virus protection is not enabled (AntivirusEnabled or RealTimeProtectionEnabled is False)."
    exit 1
}

Write-Output "Anti-virus protection is enabled (both AntivirusEnabled and RealTimeProtectionEnabled are True)."
exit 0