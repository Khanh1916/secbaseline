# Accounts are locked for 14 minutes after 5 bad passwords.
Set-SecurityPolicy @{ LockoutBadCount = 5; ResetLockoutCount = 14; LockoutDuration = 14 }
