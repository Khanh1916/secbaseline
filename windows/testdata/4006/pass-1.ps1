# Accounts are locked after 1 bad password.
Set-SecurityPolicy @{ LockoutBadCount = 1 }
