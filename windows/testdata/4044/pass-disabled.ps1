# UseLogonCredential = 0.
$wdigest = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest'
Set-RegistryValue $wdigest UseLogonCredential 0
