# Ensure the SMBv1 server protocol is disabled
function Get-RegValue([string]$Path, [string]$Name) {
    $item = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $item) { return $null }
    return $item.$Name
}

$config = Get-SmbServerConfiguration -ErrorAction SilentlyContinue
if ($config) {
    if ($config.EnableSMB1Protocol) {
        Write-Output "FAIL: SMBv1 server protocol is enabled"
        exit 1
    }
    Write-Output "PASS: SMBv1 server protocol is disabled"
    exit 0
}

$smb1 = Get-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "SMB1"
if ($smb1 -eq 0) {
    Write-Output "PASS: SMBv1 server protocol is disabled (SMB1 = 0)"
    exit 0
}

Write-Output "FAIL: Could not confirm SMBv1 is disabled; run elevated or set SMB1 = 0"
exit 1
