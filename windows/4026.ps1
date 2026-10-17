try {
    $backup_output = Get-WBPolicy -ErrorAction Stop
} catch {
    Write-Output "FAIL: Backup policy is not configured (Get-WBPolicy returned error or no policy found)"
    exit 1
}

if (-not $backup_output) {
    Write-Output "FAIL: Backup policy is not configured (Get-WBPolicy returned error or no policy found)"
    exit 1
}

Write-Output "PASS: Backup policy is configured (Get-WBPolicy returned backup policy object successfully)"
exit 0