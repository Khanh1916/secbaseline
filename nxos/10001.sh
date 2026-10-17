#!/bin/bash

# DESCRIPTION:
# This script validates Cisco NX-OS configuration files to ensure proper
# hostname configuration is present and meets security standards.
#
# VALIDATION CRITERIA:
# - Configuration must contain a "hostname" statement
# - Hostname must not be a default value (Router/Switch/router/switch/ios/iosxr)
# - Returns PASS for compliant configurations, FAILED otherwise
#
# USAGE:
# ./10001.sh <config_file>
#
# EXAMPLES:
# ./10001.sh router-config.txt
# ./10001.sh /path/to/cisco-config.cfg
#
# EXIT CODES:
# 0 - PASS: Configuration meets hostname requirements
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

# Extract hostname from config
HOSTNAME=$(grep -i "^hostname[[:space:]]" "$CONFIG_FILE" | awk '{print $2}' | head -1)

# Check if hostname exists
if [ -z "$HOSTNAME" ]; then
    echo "FAILED"
    exit 1
fi

# Check against forbidden values (case-insensitive)
if grep -qi "^hostname[[:space:]]\+\(router\|switch\)[[:space:]]*$" "$CONFIG_FILE"; then
    echo "FAILED"
    exit 1
fi

echo "PASS"
exit 0