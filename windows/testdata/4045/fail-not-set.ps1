# RunAsPPL is not set.
$lsa = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
Remove-RegistryValue $lsa RunAsPPL
