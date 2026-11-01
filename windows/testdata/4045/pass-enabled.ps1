# RunAsPPL = 1 (with a UEFI lock).
$lsa = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
Set-RegistryValue $lsa RunAsPPL 1
