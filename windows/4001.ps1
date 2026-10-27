# Ensure minimum password length is 8 or more characters
# Local security policy, [System Access] section. secedit needs an elevated session.
function Get-SecurityPolicy {
    $cfg = Join-Path $env:TEMP ("secbaseline-" + [guid]::NewGuid().ToString() + ".inf")
    try {
        secedit /export /cfg $cfg /areas SECURITYPOLICY /quiet *> $null
        if (-not (Test-Path $cfg)) { return $null }
        $policy = @{}
        foreach ($line in Get-Content $cfg) {
            if ($line -match '^\s*(\w+)\s*=\s*(-?\d+)\s*$') { $policy[$Matches[1]] = [int64]$Matches[2] }
        }
        if ($policy.Count -eq 0) { return $null }
        return $policy
    } finally {
        Remove-Item $cfg -Force -ErrorAction SilentlyContinue
    }
}

# Without elevation: net accounts prints its fields in the same order in every
# display language, so the value is read by position, not by label.
function Get-NetAccountsField([int]$Index) {
    $fields = @(net accounts 2>$null | Where-Object { $_ -match ':' })
    if ($fields.Count -le $Index) { return $null }
    return ($fields[$Index] -split ':', 2)[1].Trim()
}

$minimum = 8
$policy = Get-SecurityPolicy
if ($null -ne $policy) {
    $length = $policy["MinimumPasswordLength"]
} else {
    $field = Get-NetAccountsField 3
    $length = if ($field -match '^\d+$') { [int64]$field } else { $null }
}

if ($null -eq $length) {
    Write-Output "FAIL: Could not read the minimum password length"
    exit 1
}

if ($length -lt $minimum) {
    Write-Output "FAIL: Minimum password length is $length (minimum $minimum)"
    exit 1
}

Write-Output "PASS: Minimum password length is $length"
exit 0
