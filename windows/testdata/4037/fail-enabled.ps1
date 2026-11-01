# The SMBv1 server protocol is enabled. Windows Server 2025 has no SMBv1 server
# to turn on, so there it is enabled with the documented registry value.
try {
    Set-SmbServer @{ EnableSMB1Protocol = $true }
} catch {
    Set-RegistryValue 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' SMB1 1
}
if (-not (Get-SmbServerConfiguration).EnableSMB1Protocol) {
    Skip-Case 'Get-SmbServerConfiguration does not report SMBv1 as enabled'
}
