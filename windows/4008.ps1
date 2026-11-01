# Ensure a logon legal notice title and text are configured
function Get-RegValue([string]$Path, [string]$Name) {
    $item = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $item) { return $null }
    return $item.$Name
}

$path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
# The text may be a multi-string value, one line per string. Only spaces is
# no notice.
$caption = (@(Get-RegValue $path "legalnoticecaption") -join "").Trim()
$text = (@(Get-RegValue $path "legalnoticetext") -join "").Trim()

$missing = @()
if (-not $caption) { $missing += "title (legalnoticecaption)" }
if (-not $text) { $missing += "text (legalnoticetext)" }
if ($missing.Count -gt 0) {
    Write-Output "FAIL: The logon legal notice has no $($missing -join ' and ')"
    exit 1
}

Write-Output "PASS: A logon legal notice title and text are configured"
exit 0
