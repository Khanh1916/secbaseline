# The SMBv1 server protocol is disabled.
Set-SmbServer @{ EnableSMB1Protocol = $false }
