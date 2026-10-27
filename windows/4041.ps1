# Ensure User Account Control is enabled
function Get-RegValue([string]$Path, [string]$Name) {
    $item = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $item) { return $null }
    return $item.$Name
}

$lua = Get-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "EnableLUA"
if ($lua -ne 1) {
    Write-Output "FAIL: User Account Control is disabled (EnableLUA = $lua)"
    exit 1
}

Write-Output "PASS: User Account Control is enabled"
exit 0
