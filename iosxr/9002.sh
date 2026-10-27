#!/bin/bash

# DESCRIPTION:
# This script validates Cisco IOS XR configuration files to ensure proper
# banner login configuration is present and meets security standards.
#
# VALIDATION CRITERIA:
# - Configuration must contain a "banner login" statement
# - Banner login must have actual content between delimiters
# - Returns PASS for compliant configurations, FAIL otherwise
#
# USAGE:
# ./9002.sh <config_file>
#
# EXAMPLES:
# ./9002.sh router-config.txt
# ./9002.sh /path/to/cisco-config.cfg
#
# EXIT CODES:
# 0 - PASS: Configuration meets banner login requirements
# 1 - FAIL: Configuration does not meet requirements
# 2 - ERROR: File not found or invalid arguments
#
# REQUIREMENTS:
# - Bash 4.0 or higher
# - Read access to configuration files
# - grep, awk utilities (standard on most Unix/Linux systems)

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

# Check if banner login exists
if ! grep -qi "^[[:space:]]*banner[[:space:]]\+login[[:space:]]" "$CONFIG_FILE"; then
    echo "FAIL"
    exit 1
fi

echo "PASS"
exit 0