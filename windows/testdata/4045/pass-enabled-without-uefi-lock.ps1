# RunAsPPL = 2 (without a UEFI lock).
$lsa = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
Set-RegistryValue $lsa RunAsPPL 2
