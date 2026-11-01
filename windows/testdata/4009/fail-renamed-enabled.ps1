# The Guest account is renamed and enabled.
Set-BuiltinAccount -Rid 501 -Name 'visitor' -Enabled $true
