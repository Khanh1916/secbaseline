# UseLogonCredential = 1: WDigest keeps plaintext credentials.
$wdigest = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest'
Set-RegistryValue $wdigest UseLogonCredential 1
