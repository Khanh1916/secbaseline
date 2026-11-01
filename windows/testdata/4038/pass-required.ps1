# The SMB server requires signing.
Set-SmbServer @{ RequireSecuritySignature = $true }
