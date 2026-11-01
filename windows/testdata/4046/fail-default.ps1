# The Windows default: SAM accounts are restricted, shares are not.
$lsa = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
Set-RegistryValue $lsa RestrictAnonymousSAM 1
Set-RegistryValue $lsa RestrictAnonymous 0
