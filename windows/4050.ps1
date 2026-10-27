# Ensure PowerShell script block logging is enabled
function Get-RegValue([string]$Path, [string]$Name) {
    $item = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $item) { return $null }
    return $item.$Name
}

$value = Get-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" "EnableScriptBlockLogging"
if ($value -ne 1) {
    Write-Output "FAIL: PowerShell script block logging is not enabled"
    exit 1
}

Write-Output "PASS: PowerShell script block logging is enabled"
exit 0
