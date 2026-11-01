# Passwords are stored using reversible encryption.
Set-SecurityPolicy @{ ClearTextPassword = 1 }
