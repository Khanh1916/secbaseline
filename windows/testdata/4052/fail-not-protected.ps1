# BitLocker does not protect the system drive (it does not on GitHub's runners).
if (Get-Command Get-BitLockerVolume -ErrorAction SilentlyContinue) {
    $volume = Get-BitLockerVolume -MountPoint $env:SystemDrive -ErrorAction SilentlyContinue
    if ($volume -and $volume.ProtectionStatus -eq 'On') { Skip-Case "BitLocker protects $env:SystemDrive" }
}
