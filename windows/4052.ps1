# Ensure BitLocker protects the operating system drive
$volume = Get-BitLockerVolume -MountPoint $env:SystemDrive -ErrorAction SilentlyContinue
if (-not $volume) {
    Write-Output "FAIL: Could not read BitLocker status for $env:SystemDrive (requires an elevated session and BitLocker support)"
    exit 1
}

if ($volume.ProtectionStatus -ne "On") {
    Write-Output "FAIL: BitLocker protection is $($volume.ProtectionStatus) on $env:SystemDrive"
    exit 1
}

Write-Output "PASS: BitLocker protects $env:SystemDrive ($($volume.EncryptionMethod))"
exit 0
