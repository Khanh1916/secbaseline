#!/bin/bash

# DESCRIPTION:
# This script validates network device console and auxiliary port security configuration
# following security requirements to disable unused protocols and services to limit attack risks
#
# VALIDATION LOGIC:
# 1. Check if configuration file exists and is accessible
# 2. Validate console port has log-out-on-disconnect enabled
# 3. Verify console port is configured as insecure (no password prompt)
# 4. Ensure auxiliary port is configured as insecure (disabled)
#
# STRICT VALIDATION REQUIREMENTS:
# - Disable unused protocols and services to limit attack risks
# - Console port must have automatic logout on disconnect for security
# - Console port must be configured as insecure to prevent unauthorized access
# - Auxiliary port must be configured as insecure to disable unused service
# - All three security configurations must be present simultaneously
#
# SAMPLE CONFIGURATION:
# set system ports console log-out-on-disconnect
# set system ports console insecure
# set system ports auxiliary insecure
# set system diag-port-authentication
#
# USAGE:
# ./8007.sh <config_file>
#
# EXIT CODES:
# 0 - PASS: All three security configurations are present
# 1 - FAILED: Missing one or more required security configurations

# Check Junos configuration for console and aux ports
# PASS if all 3 security configurations are present:
#   set system ports console log-out-on-disconnect
#   set system ports console insecure
#   set system ports auxiliary insecure

if [ $# -ne 1 ]; then
    echo "Usage: $0 <junos_config_file>"
    exit 1
fi

CONFIG="$1"
[ ! -f "$CONFIG" ] && echo "FAILED" && exit 1

REQUIRED_RULES=(
    "set system ports console log-out-on-disconnect"
    "set system ports console insecure"
    "set system ports auxiliary insecure"
)

for rule in "${REQUIRED_RULES[@]}"; do
    if ! grep -qF "$rule" "$CONFIG"; then
        echo "FAILED"
        exit 1
    fi
done

echo "PASS"