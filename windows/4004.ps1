# Ensure passwords are not stored using reversible encryption
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

$policy = Get-SecurityPolicy
if ($null -eq $policy) {
    Write-Output "FAIL: Could not read the local security policy; run from an elevated session"
    exit 1
}

$cleartext = $policy["ClearTextPassword"]
if ($null -eq $cleartext) {
    Write-Output "FAIL: The reversible encryption setting is missing from the local security policy"
    exit 1
}

if ($cleartext -ne 0) {
    Write-Output "FAIL: Passwords are stored using reversible encryption"
    exit 1
}

Write-Output "PASS: Passwords are not stored using reversible encryption"
exit 0
