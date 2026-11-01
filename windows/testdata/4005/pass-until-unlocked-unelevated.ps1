# Locked accounts stay locked until unlocked, read without elevation (net accounts).
Set-SecurityPolicy @{ LockoutBadCount = 5; ResetLockoutCount = 15; LockoutDuration = -1 }
