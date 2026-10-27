# Ensure LAN Manager authentication accepts NTLMv2 only
function Get-RegValue([string]$Path, [string]$Name) {
    $item = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $item) { return $null }
    return $item.$Name
}

$level = Get-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "LmCompatibilityLevel"
if ($level -ne 5) {
    Write-Output "FAIL: LAN Manager authentication level is not 5 (send NTLMv2 only, refuse LM and NTLM); LmCompatibilityLevel = $level"
    exit 1
}

Write-Output "PASS: LAN Manager authentication accepts NTLMv2 only"
exit 0
