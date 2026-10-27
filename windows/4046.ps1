# Ensure anonymous enumeration of accounts and shares is restricted
function Get-RegValue([string]$Path, [string]$Name) {
    $item = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $item) { return $null }
    return $item.$Name
}

$path = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
$sam = Get-RegValue $path "RestrictAnonymousSAM"
$any = Get-RegValue $path "RestrictAnonymous"

if ($sam -ne 1 -or $any -ne 1) {
    Write-Output "FAIL: Anonymous enumeration is not fully restricted (RestrictAnonymousSAM = $sam, RestrictAnonymous = $any)"
    exit 1
}

Write-Output "PASS: Anonymous enumeration of SAM accounts and shares is restricted"
exit 0
