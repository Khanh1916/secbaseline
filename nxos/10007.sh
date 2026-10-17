#!/bin/bash

# DESCRIPTION:
# This script validates Cisco NX-OS configuration files to ensure proper
# authentication is configured for AUX and Console access.
#
# VALIDATION CRITERIA:
# - Must NOT have "aaa authentication login default none"
# - Must NOT have "aaa authentication login console none"
# - Returns PASS only if both criteria are met
#
# USAGE:
# ./10007.sh <config_file>
#
# EXAMPLES:
# ./10007.sh router-config.txt
# ./10007.sh /path/to/cisco-config.cfg
#
# SAMPLE CONFIGURATION:
# no aaa authentication login default none
# no aaa authentication login console none
#
# EXIT CODES:
# 0 - PASS: Authentication properly configured for AUX and Console
# 1 - FAILED: Authentication disabled for AUX or Console
# 2 - ERROR: File not found or invalid arguments
#
# REQUIREMENTS:
# - Bash 4.0 or higher
# - Read access to configuration files
# - grep utilities (standard on most Unix/Linux systems)

# Check arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 <config_file>"
    exit 1
fi

CONFIG_FILE="$1"

# Check file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "File not found: $CONFIG_FILE"
    exit 1
fi

# Function to check if any AAA authentication login has "none"
check_aaa_auth_none() {
    if grep -qi "^aaa[[:space:]]\+authentication[[:space:]]\+login.*none" "$CONFIG_FILE"; then
        echo "HAS_NONE"
    else
        echo "NO_NONE"
    fi
}

# Initialize validation status
failed=false
failure_reasons=()

# Check for any AAA authentication login with "none"
aaa_auth_status=$(check_aaa_auth_none)
if [ "$aaa_auth_status" = "HAS_NONE" ]; then
    failed=true
    failure_reasons+=("Found 'none' in AAA authentication login configuration")
fi

# Output results
if [ "$failed" = true ]; then
    echo "FAILED"
    ## Optionally output specific failure reasons (uncomment if needed)
    # for reason in "${failure_reasons[@]}"; do
    #     echo "  - $reason" >&2
    # done
    exit 1
else
    echo "PASS"
    exit 0
fi