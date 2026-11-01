# The SMBv1 server protocol is enabled. Windows Server 2025 ships without the
# SMBv1 server, so the feature is added first.
Install-ServerFeature FS-SMB1
try {
    Set-SmbServer @{ EnableSMB1Protocol = $true }
} catch {
    Skip-Case "the SMBv1 server cannot be enabled here: $_"
}
