# Accounts are locked for 14 minutes, read without elevation (net accounts).
Set-SecurityPolicy @{ LockoutBadCount = 5; ResetLockoutCount = 14; LockoutDuration = 14 }
