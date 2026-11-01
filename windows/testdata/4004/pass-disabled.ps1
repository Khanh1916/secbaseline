# Passwords are not stored using reversible encryption.
Set-SecurityPolicy @{ ClearTextPassword = 0 }
