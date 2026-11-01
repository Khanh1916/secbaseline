# The Guest account is renamed and disabled.
Set-BuiltinAccount -Rid 501 -Name 'visitor' -Enabled $false
