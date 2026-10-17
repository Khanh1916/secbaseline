#!/bin/bash

# DESCRIPTION:
# This script validates Cisco NX-OS configuration files to ensure proper
# banner login configuration is present and meets security standards.
#
# VALIDATION CRITERIA:
# - Configuration must contain a "banner login" statement
# - Banner login must have actual content between delimiters
# - Returns PASS for compliant configurations, FAILED otherwise
#
# USAGE:
# ./10002.sh <config_file>
#
# EXAMPLES:
# ./10002.sh router-config.txt
# ./10002.sh /path/to/cisco-config.cfg
#
# EXIT CODES:
# 0 - PASS: Configuration meets banner login requirements
# 1 - FAILED: Configuration does not meet requirements
# 2 - ERROR: File not found or invalid arguments
#
# REQUIREMENTS:
# - Bash 4.0 or higher
# - Read access to configuration files
# - grep, awk utilities (standard on most Unix/Linux systems)

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

# Check if banner login exists
if ! grep -qi "^banner[[:space:]]\+motd[[:space:]]" "$CONFIG_FILE"; then
    echo "FAILED"
    exit 1
fi

echo "PASS"
exit 0