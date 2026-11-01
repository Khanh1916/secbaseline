# Accounts are locked for 15 minutes, read without elevation (net accounts).
Set-SecurityPolicy @{ LockoutBadCount = 5; ResetLockoutCount = 15; LockoutDuration = 15 }
