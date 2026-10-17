# Windows Login Banner Check - Legal Notice
$reg_path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"

# Check legalnoticetext
$text_value = Get-ItemProperty -Path $reg_path -Name "legalnoticetext" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty legalnoticetext

# Check legalnoticecaption
$caption_value = Get-ItemProperty -Path $reg_path -Name "legalnoticecaption" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty legalnoticecaption

if ((-not $text_value) -or (-not $caption_value)) {
    Write-Output "Login banner is not configured (legalnoticetext or legalnoticecaption is empty)."
    exit 1
}

Write-Output "Login banner is properly configured (both legalnoticetext and legalnoticecaption are set)."
exit 0
