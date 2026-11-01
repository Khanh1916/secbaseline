# UseLogonCredential is not set: off since Windows 8.1.
$wdigest = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest'
Remove-RegistryValue $wdigest UseLogonCredential
