#!/bin/bash

# DESCRIPTION:
# This script validates Cisco NX-OS configuration files to ensure proper
# NTP time synchronization and timezone configuration (GMT+7).
#
# VALIDATION CRITERIA:
# - Must have "clock timezone ... 7 0" (GMT+7 timezone)
# - Must have at least one "ntp server ..." configuration
# - Returns PASS only if both criteria are met
#
# USAGE:
# ./10009.sh <config_file>
#
# EXAMPLES:
# ./10009.sh router-config.txt
# ./10009.sh /path/to/cisco-config.cfg
#
# SAMPLE CONFIGURATION:
# clock timezone HaNoi 7 0
# ntp server 1.vn.pool.ntp.org use-vrf management
# ntp server 1.asia.pool.ntp.org use-vrf management
# ntp source-interface mgmt0
#
# EXIT CODES:
# 0 - PASS: NTP and timezone properly configured
# 1 - FAIL: Missing or incorrect NTP/timezone configuration
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

# Function to check timezone configuration (GMT+7)
check_timezone_config() {
    # Check for "clock timezone ... 7 0" - timezone offset +7 hours, 0 minutes
    if grep -qi "^clock[[:space:]]\+timezone[[:space:]]\+[^[:space:]]\+[[:space:]]\+7[[:space:]]\+0" "$CONFIG_FILE"; then
        echo "CONFIGURED"
    else
        echo "NOT_CONFIGURED"
    fi
}

# Function to check NTP server configuration
check_ntp_server_config() {
    # Check for any "ntp server ..." configuration
    if grep -qi "^ntp[[:space:]]\+server[[:space:]]\+" "$CONFIG_FILE"; then
        echo "CONFIGURED"
    else
        echo "NOT_CONFIGURED"
    fi
}

# Initialize validation status
failed=false
failure_reasons=()

# Check timezone configuration
timezone_status=$(check_timezone_config)
if [ "$timezone_status" != "CONFIGURED" ]; then
    failed=true
    failure_reasons+=("Missing or incorrect timezone configuration (required: clock timezone ... 7 0)")
fi

# Check NTP server configuration
ntp_status=$(check_ntp_server_config)
if [ "$ntp_status" != "CONFIGURED" ]; then
    failed=true
    failure_reasons+=("Missing NTP server configuration (required: ntp server ...)")
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