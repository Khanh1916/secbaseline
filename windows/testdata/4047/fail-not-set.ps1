# LmCompatibilityLevel is not set (the default is 3).
$lsa = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
Remove-RegistryValue $lsa LmCompatibilityLevel
