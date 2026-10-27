# Ensure the SMB server requires message signing
function Get-RegValue([string]$Path, [string]$Name) {
    $item = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $item) { return $null }
    return $item.$Name
}

$config = Get-SmbServerConfiguration -ErrorAction SilentlyContinue
if ($config) {
    $required = $config.RequireSecuritySignature
} else {
    $required = (Get-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "RequireSecuritySignature") -eq 1
}

if (-not $required) {
    Write-Output "FAIL: SMB server does not require message signing"
    exit 1
}

Write-Output "PASS: SMB server requires message signing"
exit 0
