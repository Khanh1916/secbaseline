# Anonymous enumeration of SAM accounts and of shares is restricted.
$lsa = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
Set-RegistryValue $lsa RestrictAnonymousSAM 1
Set-RegistryValue $lsa RestrictAnonymous 1
