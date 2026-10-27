#!/bin/bash

# DESCRIPTION:
# This script validates Cisco NX-OS configuration files to ensure proper
# AAA authentication rejected configuration is enabled to prevent brute force attacks.
#
# VALIDATION CRITERIA:
# - Must have "aaa authentication rejected ..." configuration if AAA is configured
# - Returns PASS if AAA auth rejected is configured, FAIL if not configured
#
# USAGE:
# ./10014.sh <config_file>
#
# EXAMPLES:
# ./10014.sh router-config.txt
# ./10014.sh /path/to/cisco-config.cfg
#
# SAMPLE CONFIGURATION:
# aaa authentication rejected 5 in 300 ban 600 
# aaa authentication login invalid-username-log
#
# EXIT CODES:
# 0 - PASS: AAA authentication rejected is properly configured
# 1 - FAIL: AAA authentication rejected is not configured
# 2 - ERROR: File not found or invalid arguments
#
# REQUIREMENTS:
# - Bash 4.0 or higher
# - Read access to configuration files
# - grep utilities (standard on most Unix/Linux systems)

# Check arguments
if [ $# -ne 1 ]; then
    echo "FAIL"
    exit 1
fi

CONFIG_FILE="$1"

# Check file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "FAIL"
    exit 1
fi

# Function to check AAA authentication rejected configuration
check_aaa_auth_rejected() {
    # Check for "aaa authentication rejected" configuration
    # ...or login quiet mode: "login block-for <s> attempts <n> within <s>"
    if grep -qi "^aaa[[:space:]]\+authentication[[:space:]]\+rejected[[:space:]]\+" "$CONFIG_FILE" || \
       grep -qi "^login[[:space:]]\+block-for[[:space:]]\+[0-9]\+[[:space:]]\+attempts[[:space:]]\+" "$CONFIG_FILE"; then
        echo "AAA_AUTH_REJECTED_CONFIGURED"
    else
        echo "AAA_AUTH_REJECTED_NOT_CONFIGURED"
    fi
}

# Initialize validation status
failed=false
failure_reasons=()

# Check AAA authentication rejected configuration
aaa_auth_rejected_status=$(check_aaa_auth_rejected)
if [ "$aaa_auth_rejected_status" != "AAA_AUTH_REJECTED_CONFIGURED" ]; then
    failed=true
    failure_reasons+=("AAA authentication rejected not configured (missing 'aaa authentication rejected ...')")
fi

# Output results
if [ "$failed" = true ]; then
    echo "FAIL"
    # Optionally output specific failure reasons (uncomment if needed)
    # for reason in "${failure_reasons[@]}"; do
    #     echo "  - $reason" >&2
    # done
    exit 1
else
    echo "PASS"
    exit 0
fi