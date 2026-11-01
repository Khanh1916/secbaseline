# Accounts are locked for 15 minutes after 5 bad passwords.
Set-SecurityPolicy @{ LockoutBadCount = 5; ResetLockoutCount = 15; LockoutDuration = 15 }
