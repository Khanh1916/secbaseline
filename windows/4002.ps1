# Ensure password complexity requirements are enabled
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

if ($policy["PasswordComplexity"] -ne 1) {
    Write-Output "FAIL: Password complexity requirements are not enabled"
    exit 1
}

Write-Output "PASS: Password complexity requirements are enabled"
exit 0
