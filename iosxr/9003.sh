#!/bin/bash

# DESCRIPTION:
# This script validates Cisco IOS XR configuration files to ensure proper
# exec-timeout configuration is present and meets security standards.
# Administrators should configure EXEC timeout on network devices to automatically 
# disconnect idle user sessions after a specified period of inactivity. This practice 
# helps enhance security by preventing unauthorized access through potentially abandoned 
# sessions by users who have forgotten to log off and terminate their session properly.
#
# VALIDATION CRITERIA:
# - Configuration must contain "line default" with "exec-timeout 5 0"
# - All exec-timeout configurations must be exactly "exec-timeout 5 0"
# - Checks exec-timeout in any context (line console, line default, interface, etc.)
# - Returns PASS for compliant configurations, FAILED otherwise
#
# USAGE:
# ./9003.sh <config_file>
#
# EXAMPLES:
# ./9003.sh router-config.txt
# ./9003.sh /path/to/cisco-config.cfg
#
# SAMPLE CONFIGURATIONS:
# line default
#  exec-timeout 5 0
# line console
#  exec-timeout 5 0
# line template SSH-TEMP
#  exec-timeout 5 0
#
# EXIT CODES:
# 0 - PASS: Configuration meets exec-timeout requirements
# 1 - FAILED: Configuration does not meet requirements
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

# Check if any exec-timeout exists
if ! grep -qi "exec-timeout" "$CONFIG_FILE"; then
    echo "FAILED"
    exit 1
fi

# Check if "line default" exists and has "exec-timeout 5 0"
LINE_DEFAULT_FOUND=false
EXEC_TIMEOUT_AFTER_DEFAULT=false

# Read file line by line to check line default context
while IFS= read -r line; do
    # Check for line default
    if echo "$line" | grep -qi "^[[:space:]]*line[[:space:]]\+default[[:space:]]*$"; then
        LINE_DEFAULT_FOUND=true
        continue
    fi
    
    # If we found line default, check next lines for exec-timeout
    if [ "$LINE_DEFAULT_FOUND" = true ]; then
        if echo "$line" | grep -qi "^[[:space:]]*exec-timeout[[:space:]]\+5[[:space:]]\+0[[:space:]]*$"; then
            EXEC_TIMEOUT_AFTER_DEFAULT=true
            LINE_DEFAULT_FOUND=false
        elif echo "$line" | grep -qi "^[[:space:]]*line[[:space:]]"; then
            # Found another line command, reset
            LINE_DEFAULT_FOUND=false
        elif echo "$line" | grep -qi "^[[:space:]]*!"; then
            # Found comment/end marker, reset
            LINE_DEFAULT_FOUND=false
        fi
    fi
done < "$CONFIG_FILE"

# Check if line default has exec-timeout 5 0
if [ "$EXEC_TIMEOUT_AFTER_DEFAULT" = false ]; then
    echo "FAILED"
    exit 1
fi

# All exec-timeout must be exactly "exec-timeout 5 0"
while IFS= read -r line; do
    if ! echo "$line" | grep -qi "exec-timeout[[:space:]]\+5[[:space:]]\+0"; then
        echo "FAILED"
        exit 1
    fi
done < <(grep -i "exec-timeout" "$CONFIG_FILE")

echo "PASS"
exit 0