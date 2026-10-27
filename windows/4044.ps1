# Ensure WDigest does not store plaintext credentials
function Get-RegValue([string]$Path, [string]$Name) {
    $item = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $item) { return $null }
    return $item.$Name
}

$value = Get-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" "UseLogonCredential"
if ($value -eq 1) {
    Write-Output "FAIL: WDigest stores plaintext credentials in memory (UseLogonCredential = 1)"
    exit 1
}

Write-Output "PASS: WDigest does not store plaintext credentials (UseLogonCredential is not 1)"
exit 0
