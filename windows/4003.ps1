# Ensure password history remembers 24 or more passwords
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

$minimum = 24
$policy = Get-SecurityPolicy
if ($null -ne $policy) {
    $history = $policy["PasswordHistorySize"]
} else {
    $field = Get-NetAccountsField 4
    # A word instead of a number means no history ("None").
    $history = if ($null -eq $field) { $null } elseif ($field -match '^\d+$') { [int64]$field } else { 0 }
}

if ($null -eq $history) {
    Write-Output "FAIL: Could not read the password history length"
    exit 1
}

if ($history -lt $minimum) {
    Write-Output "FAIL: Password history remembers $history passwords (minimum $minimum)"
    exit 1
}

Write-Output "PASS: Password history remembers $history passwords"
exit 0
