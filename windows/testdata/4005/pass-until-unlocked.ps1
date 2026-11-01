# Locked accounts stay locked until an administrator unlocks them (-1).
Set-SecurityPolicy @{ LockoutBadCount = 5; ResetLockoutCount = 15; LockoutDuration = -1 }
