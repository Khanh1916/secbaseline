#!/bin/bash

# DESCRIPTION:
# This script validates network device login idle timeout configuration
# following security requirements for automatic session termination
#
# VALIDATION LOGIC:
# 1. Check if configuration file exists and is accessible
# 2. Extract all login classes defined in the configuration
# 3. Validate each class has idle-timeout set to 5 minutes
# 4. Check system-wide default idle-timeout is set to 5 minutes
#
# STRICT VALIDATION REQUIREMENTS:
# - System default idle-timeout must be set to 5 minutes
# - All login classes must have idle-timeout configured to 5 minutes
# - Limits session time when no data is transmitted over remote or console sessions
# - Sessions automatically disconnect after 5 minutes of inactivity for security
# - Note: Idle timeout limitation does not apply to super-user class (Junos does not support)
#
# SAMPLE CONFIGURATION:
# set system login idle-timeout 5
# set system login class netadmin idle-timeout 5
# set system login class operation idle-timeout 5
# set system login class super-user-local idle-timeout 5
#
# USAGE:
# ./8003.sh <config_file>
#
# EXIT CODES:
# 0 - PASS: All idle timeout configurations are properly set to 5 minutes
# 1 - FAILED: Missing or incorrect idle timeout configuration

# Check input arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 <path-to-junos-config.set>"
    exit 1
fi

CONFIG_FILE="$1"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: File not found: $CONFIG_FILE"
    exit 1
fi

status="PASS"

# Get list of all classes in configuration
classes=$(grep -oP 'set system login class \K\S+' "$CONFIG_FILE" | sort -u)

# Check each class has idle-timeout 5
for class in $classes; do
    timeout_line=$(grep "set system login class $class idle-timeout" "$CONFIG_FILE")

    if [[ -z "$timeout_line" ]]; then
        status="FAILED"
        break
    else
        value=$(echo "$timeout_line" | awk '{print $NF}')
        if [[ "$value" -ne 5 ]]; then
            status="FAILED"
            break
        fi
    fi
done

# Check default configuration: set system login idle-timeout 5
default_idle=$(grep -E "^set system login idle-timeout[ ]+5$" "$CONFIG_FILE")

if [[ -z "$default_idle" ]]; then
    status="FAILED"
fi

# Print final result
echo "$status"