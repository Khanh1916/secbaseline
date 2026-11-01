# Accounts are locked after 6 bad passwords.
Set-SecurityPolicy @{ LockoutBadCount = 6 }
