# Send NTLMv2 only, but accept LM and NTLM (3).
$lsa = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
Set-RegistryValue $lsa LmCompatibilityLevel 3
