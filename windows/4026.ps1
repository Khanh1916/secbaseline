try {
    $backup_output = Get-WBPolicy -ErrorAction Stop
} catch {
    Write-Output "Backup policy is not configured (Get-WBPolicy returned error or no policy found)."
    exit 1
}

if (-not $backup_output) {
    Write-Output "Backup policy is not configured (Get-WBPolicy returned error or no policy found)."
    exit 1
}

Write-Output "Backup policy is configured (Get-WBPolicy returned backup policy object successfully)."
exit 0