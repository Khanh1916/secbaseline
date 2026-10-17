#!/bin/bash

# DESCRIPTION:
# This script validates Juniper device login retry options configuration
# to ensure adequate security parameters against brute force attacks
# and password guessing attacks.
#
# VALIDATION LOGIC:
# 1. Check if configuration file exists and is accessible
# 2. Validate backoff-factor configuration for wait time multiplier
# 3. Verify backoff-threshold configuration for activation threshold
# 4. Check lockout-period configuration for account lock duration
# 5. Ensure tries-before-disconnect configuration for maximum attempts
#
# STRICT VALIDATION REQUIREMENTS:
# - Configure failed authentication attempts count (if AAA is enabled)
# - Configure protection against brute-force password guessing
# - Protection against brute-force password guessing with:
#   * backoff-factor - Wait time multiplier coefficient
#   * backoff-threshold - Threshold to activate backoff mechanism
#   * lockout-period - Account lock time (seconds)
#   * tries-before-disconnect - Maximum attempts count
# - ALL 4 PARAMETERS MUST BE PRESENT TO ENSURE BRUTE FORCE PROTECTION
#
# LOGIN RETRY OPTIONS REQUIREMENTS:
# [1] BACKOFF FACTOR CONFIGURATION
#     * Configure multiplier coefficient for wait time after each failed attempt
#     * Validates: set system login retry-options backoff-factor <value>
#
# [2] BACKOFF THRESHOLD CONFIGURATION
#     * Configure threshold to activate backoff mechanism
#     * Validates: set system login retry-options backoff-threshold <value>
#
# [3] LOCKOUT PERIOD CONFIGURATION
#     * Configure account lock time after exceeding limits
#     * Validates: set system login retry-options lockout-period <seconds>
#
# [4] TRIES BEFORE DISCONNECT CONFIGURATION
#     * Configure maximum attempts before disconnecting
#     * Validates: set system login retry-options tries-before-disconnect <count>
#
# SAMPLE CONFIGURATION:
# set system login retry-options backoff-factor 5
# set system login retry-options backoff-threshold 2
# set system login retry-options lockout-period 300
# set system login retry-options tries-before-disconnect 3
#
# USAGE:
# ./8014.sh <config_file>
#
# EXIT CODES:
# 0 - PASS: Protection against brute-force password guessing with backoff-factor, backoff-threshold, lockout-period, tries-before-disconnect
# 1 - FAILED: Missing one or more retry options parameters

CONFIG_FILE="$1"

# Function to display usage
# show_usage() {
#     echo "Usage: $0 <config_file>"
#     echo ""
#     echo "Parameters:"
#     echo "  config_file  - Junos configuration file (required)"
#     echo ""
#     echo "Examples:"
#     echo "  $0 config.txt"
#     echo "  $0 /path/to/junos.conf"
#     echo ""
#     echo "Required configurations:"
#     echo "  set system login retry-options backoff-factor <value>"
#     echo "  set system login retry-options backoff-threshold <value>"
#     echo "  set system login retry-options lockout-period <seconds>"
#     echo "  set system login retry-options tries-before-disconnect <count>"
# }

# Validate input parameters
if [[ -z "$CONFIG_FILE" ]]; then
    echo "FAILED"
    # show_usage >&2
    exit 1
fi

# Check if config file exists and is readable
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "FAILED"
    exit 1
fi

if [[ ! -r "$CONFIG_FILE" ]]; then
    echo "FAILED"
    exit 1
fi

# Function to check backoff-factor configuration
check_backoff_factor() {
    if grep -E "set system login retry-options.*backoff-factor" "$CONFIG_FILE" >/dev/null 2>&1; then
        return 0
    fi
    
    return 1
}

# Function to check backoff-threshold configuration
check_backoff_threshold() {
    if grep -E "set system login retry-options.*backoff-threshold" "$CONFIG_FILE" >/dev/null 2>&1; then
        return 0
    fi
    
    return 1
}

# Function to check lockout-period configuration
check_lockout_period() {
    if grep -E "set system login retry-options.*lockout-period" "$CONFIG_FILE" >/dev/null 2>&1; then
        return 0
    fi
    
    return 1
}

# Function to check tries-before-disconnect configuration
check_tries_before_disconnect() {
    if grep -E "set system login retry-options.*tries-before-disconnect" "$CONFIG_FILE" >/dev/null 2>&1; then
        return 0
    fi
    
    return 1
}

# Main validation logic
check_retry_options() {
    # Check all four required retry options parameters
    
    # 1. Check backoff-factor
    if ! check_backoff_factor; then
        return 1
    fi
    
    # 2. Check backoff-threshold
    if ! check_backoff_threshold; then
        return 1
    fi
    
    # 3. Check lockout-period
    if ! check_lockout_period; then
        return 1
    fi
    
    # 4. Check tries-before-disconnect
    if ! check_tries_before_disconnect; then
        return 1
    fi
    
    return 0
}

# Execute main check
if check_retry_options; then
    echo "PASS"
else
    echo "FAILED"
fi