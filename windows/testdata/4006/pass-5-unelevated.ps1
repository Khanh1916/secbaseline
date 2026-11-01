# Accounts are locked after 5 bad passwords, read without elevation (net accounts).
Set-SecurityPolicy @{ LockoutBadCount = 5 }
