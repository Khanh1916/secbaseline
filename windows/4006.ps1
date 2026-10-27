# Ensure account lockout threshold is between 1 and 5 attempts
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

$policy = Get-SecurityPolicy
if ($null -ne $policy) {
    $threshold = $policy["LockoutBadCount"]
} else {
    $field = Get-NetAccountsField 5
    # A word instead of a number means no lockout ("Never").
    $threshold = if ($null -eq $field) { $null } elseif ($field -match '^\d+$') { [int64]$field } else { 0 }
}

if ($null -eq $threshold) {
    Write-Output "FAIL: Could not read the account lockout threshold"
    exit 1
}

if ($threshold -eq 0) {
    Write-Output "FAIL: Account lockout is disabled (threshold 0)"
    exit 1
}

if ($threshold -gt 5) {
    Write-Output "FAIL: Account lockout threshold is $threshold attempts (expected 1 to 5)"
    exit 1
}

Write-Output "PASS: Account lockout threshold is $threshold attempts"
exit 0
