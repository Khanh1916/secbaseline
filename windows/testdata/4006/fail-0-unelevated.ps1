# Account lockout is disabled, read without elevation (net accounts prints Never).
Set-SecurityPolicy @{ LockoutBadCount = 0 }
