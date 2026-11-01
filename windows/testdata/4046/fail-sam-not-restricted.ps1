# Shares are restricted, SAM accounts are not.
$lsa = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
Set-RegistryValue $lsa RestrictAnonymousSAM 0
Set-RegistryValue $lsa RestrictAnonymous 1
