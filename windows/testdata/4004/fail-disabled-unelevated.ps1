# Reversible encryption is off, but without elevation the policy cannot be read.
Set-SecurityPolicy @{ ClearTextPassword = 0 }
