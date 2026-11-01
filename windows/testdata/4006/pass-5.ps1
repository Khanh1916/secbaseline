# Accounts are locked after 5 bad passwords.
Set-SecurityPolicy @{ LockoutBadCount = 5 }
