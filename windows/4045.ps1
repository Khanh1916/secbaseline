# Ensure LSA protection (RunAsPPL) is enabled
function Get-RegValue([string]$Path, [string]$Name) {
    $item = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $item) { return $null }
    return $item.$Name
}

$ppl = Get-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "RunAsPPL"
if ($ppl -ne 1 -and $ppl -ne 2) {
    Write-Output "FAIL: LSA protection is not enabled (RunAsPPL is not 1 or 2)"
    exit 1
}

Write-Output "PASS: LSA protection is enabled (RunAsPPL = $ppl)"
exit 0
