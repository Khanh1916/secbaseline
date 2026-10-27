# Ensure account lockout duration is 15 minutes or more
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

$minimum = 15
$policy = Get-SecurityPolicy
if ($null -ne $policy) {
    # -1 keeps an account locked until an administrator unlocks it.
    $duration = $policy["LockoutDuration"]
} else {
    $field = Get-NetAccountsField 6
    # A word instead of a number ("Never") means locked until unlocked.
    $duration = if ($null -eq $field) { $null } elseif ($field -match '^\d+$') { [int64]$field } else { -1 }
}

if ($null -eq $duration) {
    Write-Output "FAIL: Account lockout duration is not configured or could not be read"
    exit 1
}

if ($duration -eq -1) {
    Write-Output "PASS: Locked accounts stay locked until an administrator unlocks them"
    exit 0
}

if ($duration -lt $minimum) {
    Write-Output "FAIL: Account lockout duration is $duration minutes (minimum $minimum)"
    exit 1
}

Write-Output "PASS: Account lockout duration is $duration minutes"
exit 0
