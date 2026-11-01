# Windows Server Backup is not installed, so Get-WBPolicy does not exist.
if (Get-Command Get-WBPolicy -ErrorAction SilentlyContinue) { Skip-Case 'Windows Server Backup is installed' }
