# Ensure UAC prompts administrators for consent on the secure desktop
function Get-RegValue([string]$Path, [string]$Name) {
    $item = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $item) { return $null }
    return $item.$Name
}

$path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$behavior = Get-RegValue $path "ConsentPromptBehaviorAdmin"
$secure = Get-RegValue $path "PromptOnSecureDesktop"

if ($behavior -ne 2 -or $secure -eq 0) {
    Write-Output "FAIL: UAC does not prompt administrators for consent on the secure desktop (ConsentPromptBehaviorAdmin = $behavior, PromptOnSecureDesktop = $secure)"
    exit 1
}

Write-Output "PASS: UAC prompts administrators for consent on the secure desktop"
exit 0
