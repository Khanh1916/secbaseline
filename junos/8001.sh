#!/bin/bash

# DESCRIPTION:
# This script validates network device configuration by checking hostname settings
# following strict validation logic for proper device identification
#
# VALIDATION LOGIC:
# 1. Check if configuration file exists and is accessible
# 2. Search for hostname configuration line in the format "set system host-name"
# 3. Extract hostname value from configuration
# 4. Validate hostname is not set to default "Amnesiac" value
#
# STRICT VALIDATION REQUIREMENTS:
# - Configuration file must exist and be readable
# - Must contain "set system host-name" directive
# - Hostname value must not be "Amnesiac" (default/unconfigured state)
# - Hostname must be explicitly configured to a meaningful value
#
# SAMPLE CONFIGURATION:
# # Example 1: PASS - Properly configured hostname
# set system host-name ROUTER-01
# set system domain-name company.com
#
# # Example 2: FAILED - Default hostname (unconfigured)
# set system host-name Amnesiac
# set system domain-name company.com
#
# # Example 3: FAILED - Missing hostname configuration
# set system domain-name company.com
#
# USAGE:
# ./8001.sh <config_file>
#
# EXIT CODES:
# 0 - PASS: Hostname is properly configured
# 1 - FAILED: Hostname is not configured or set to default "Amnesiac"

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

# Find hostname line
hostname_line=$(grep "^set system host-name" "$CONFIG_FILE")

# If no hostname line exists → FAILED
if [ -z "$hostname_line" ]; then
    echo "FAILED"
    exit 1
fi

hostname=$(echo "$hostname_line" | awk '{print $4}')

if [[ "$hostname" == "Amnesiac" ]]; then
    echo "FAILED"
else
    echo "PASS"
fi