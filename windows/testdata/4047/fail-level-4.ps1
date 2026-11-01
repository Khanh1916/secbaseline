# Send NTLMv2 only, refuse LM only (4).
$lsa = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
Set-RegistryValue $lsa LmCompatibilityLevel 4
