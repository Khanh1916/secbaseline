# Ensure UAC prompts administrators for consent or credentials on the secure desktop
function Get-RegValue([string]$Path, [string]$Name) {
    $item = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $item) { return $null }
    return $item.$Name
}

$path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
# 1 = prompt for credentials on the secure desktop, 2 = prompt for consent on
# the secure desktop; the other values prompt on the user's desktop or not at all.
$behavior = Get-RegValue $path "ConsentPromptBehaviorAdmin"
# Unset means on.
$secure = Get-RegValue $path "PromptOnSecureDesktop"

if (($behavior -ne 1 -and $behavior -ne 2) -or $secure -eq 0) {
    Write-Output "FAIL: UAC does not prompt administrators on the secure desktop (ConsentPromptBehaviorAdmin = $behavior, PromptOnSecureDesktop = $secure)"
    exit 1
}

if ($behavior -eq 1) {
    Write-Output "PASS: UAC prompts administrators for credentials on the secure desktop"
    exit 0
}

Write-Output "PASS: UAC prompts administrators for consent on the secure desktop"
exit 0
