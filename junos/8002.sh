#!/bin/bash

# DESCRIPTION:
# This script validates network device configuration by checking login announcement settings
# following security compliance requirements for proper user notification
#
# VALIDATION LOGIC:
# 1. Check if configuration file exists and is accessible
# 2. Search for system login announcement configuration directive
# 3. Validate that announcement message is properly configured
# 4. Ensure compliance with security banner requirements
#
# STRICT VALIDATION REQUIREMENTS:
# - Configuration file must exist and be readable
# - Must contain "set system login announcement" directive
# - Announcement message can be quoted string or unquoted text
# - Banner message must be explicitly configured for security compliance
#
# SAMPLE CONFIGURATION:
# set system login announcement "Unauthorized access prohibited"
#
# USAGE:
# ./8002.sh <config_file>
#
# EXIT CODES:
# 0 - PASS: Login announcement is properly configured
# 1 - FAILED: Login announcement is missing or not configured

# Check arguments
if [ $# -ne 1 ]; then
    echo "FAILED"
    exit 1
fi

CONFIG_FILE="$1"

# Check file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "FAILED"
    exit 1
fi

# Search for system login announcement configuration
# Matches: set system login announcement "quoted message" or set system login announcement unquoted-text
if grep -Eq 'set[[:space:]]+system[[:space:]]+login[[:space:]]+announcement[[:space:]]+("[^"]+"|\S+)' "$CONFIG_FILE"; then
    echo "PASS"
else
    echo "FAILED"
fi