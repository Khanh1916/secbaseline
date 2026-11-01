# A daily backup of a folder to a volume other than the system drive.
Install-WindowsServerBackup
$volume = Get-Volume | Where-Object { $_.DriveLetter -and $_.DriveType -eq 'Fixed' -and "$($_.DriveLetter):" -ne $env:SystemDrive } |
    Select-Object -First 1
if (-not $volume) { Skip-Case 'no volume other than the system drive to back up to' }
$policy = New-WBPolicy
Add-WBFileSpec -Policy $policy -FileSpec (New-WBFileSpec -FileSpec "$env:SystemRoot\System32\drivers\etc")
Add-WBBackupTarget -Policy $policy -Target (New-WBBackupTarget -VolumePath "$($volume.DriveLetter):") | Out-Null
Set-WBSchedule -Policy $policy -Schedule ([datetime]'03:00') | Out-Null
Set-BackupPolicy $policy
