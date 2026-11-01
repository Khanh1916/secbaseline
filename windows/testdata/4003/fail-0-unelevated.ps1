# No password history, read without elevation (net accounts prints None).
Set-SecurityPolicy @{ PasswordHistorySize = 0 }
