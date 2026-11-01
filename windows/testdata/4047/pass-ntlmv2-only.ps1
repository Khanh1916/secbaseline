# Send NTLMv2 only, refuse LM and NTLM (5).
$lsa = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
Set-RegistryValue $lsa LmCompatibilityLevel 5
