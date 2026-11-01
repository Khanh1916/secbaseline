# Accounts are locked after 6 bad passwords, read without elevation (net accounts).
Set-SecurityPolicy @{ LockoutBadCount = 6 }
