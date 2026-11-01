# The SMB server does not require signing.
Set-SmbServer @{ RequireSecuritySignature = $false }
