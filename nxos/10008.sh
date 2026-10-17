#!/bin/bash

# DESCRIPTION:
# This script validates Cisco NX-OS configuration files to ensure proper
# centralized authentication using RADIUS or TACACS+ is configured.
#
# VALIDATION CRITERIA:
# - Must have "aaa authentication login default group ..." 
# - Must have "aaa authentication login console group ..."
# - At least one group from above lines must have corresponding server block:
#   - "aaa group server radius <GROUP_NAME>" OR
#   - "aaa group server tacacs+ <GROUP_NAME>"
# - Returns PASS only if all criteria are met
#
# USAGE:
# ./10008.sh <config_file>
#
# EXAMPLES:
# ./10008.sh router-config.txt
# ./10008.sh /path/to/cisco-config.cfg
#
# SAMPLE CONFIGURATION:
# aaa authentication login default group TACGRP RADGRP
# aaa authentication login console group TACGRP RADGRP
# aaa group server radius RADGRP
#     server 192.168.89.121
#     server 192.168.89.122
# aaa group server tacacs+ TACGRP
#     server 192.168.89.111
#     server 192.168.89.112
#
# EXIT CODES:
# 0 - PASS: Centralized authentication properly configured
# 1 - FAIL: Missing or incorrect centralized authentication
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

# Function to extract groups from an authentication line
extract_groups_from_auth_line() {
    local auth_type="$1"  # "default" or "console"
    
    # Find the authentication line and extract everything after "group"
    awk -v auth_type="$auth_type" '
    BEGIN { IGNORECASE = 1 }
    /^aaa[[:space:]]+authentication[[:space:]]+login[[:space:]]+/ {
        if (tolower($4) == tolower(auth_type) && /group/) {
            # Find position of "group" and extract everything after it
            for (i = 1; i <= NF; i++) {
                if (tolower($i) == "group") {
                    for (j = i + 1; j <= NF; j++) {
                        print $j
                    }
                    break
                }
            }
        }
    }
    ' "$CONFIG_FILE"
}

# Function to check if a group has corresponding server block
check_group_has_server() {
    local group_name="$1"
    
    # Check for radius server block
    if grep -qi "^aaa[[:space:]]\+group[[:space:]]\+server[[:space:]]\+radius[[:space:]]\+${group_name}[[:space:]]*$" "$CONFIG_FILE"; then
        echo "HAS_SERVER"
        return
    fi
    
    # Check for tacacs+ server block
    if grep -qi "^aaa[[:space:]]\+group[[:space:]]\+server[[:space:]]\+tacacs+[[:space:]]\+${group_name}[[:space:]]*$" "$CONFIG_FILE"; then
        echo "HAS_SERVER"
        return
    fi
    
    echo "NO_SERVER"
}

# Function to check if authentication line exists
check_auth_line_exists() {
    local auth_type="$1"  # "default" or "console"
    
    if grep -qi "^aaa[[:space:]]\+authentication[[:space:]]\+login[[:space:]]\+${auth_type}[[:space:]]\+.*group" "$CONFIG_FILE"; then
        echo "EXISTS"
    else
        echo "NOT_EXISTS"
    fi
}

# Initialize validation status
failed=false
failure_reasons=()

# Check if both required authentication lines exist
default_auth_exists=$(check_auth_line_exists "default")
console_auth_exists=$(check_auth_line_exists "console")

if [ "$default_auth_exists" != "EXISTS" ]; then
    failed=true
    failure_reasons+=("Missing 'aaa authentication login default group' configuration")
fi

if [ "$console_auth_exists" != "EXISTS" ]; then
    failed=true
    failure_reasons+=("Missing 'aaa authentication login console group' configuration")
fi

# If both lines exist, check if ALL groups have server block
if [ "$default_auth_exists" = "EXISTS" ] && [ "$console_auth_exists" = "EXISTS" ]; then
    # Extract all groups from both lines
    all_groups=""
    
    # Get groups from default line
    default_groups=$(extract_groups_from_auth_line "default")
    all_groups="$all_groups $default_groups"
    
    # Get groups from console line
    console_groups=$(extract_groups_from_auth_line "console")
    all_groups="$all_groups $console_groups"
    
    # Check if ALL groups have server block (not just one)
    has_valid_group=true
    missing_groups=()
    
    for group in $all_groups; do
        if [ -n "$group" ]; then
            group_status=$(check_group_has_server "$group")
            if [ "$group_status" != "HAS_SERVER" ]; then
                has_valid_group=false
                missing_groups+=("$group")
            fi
        fi
    done
    
    if [ "$has_valid_group" = false ]; then
        failed=true
        failure_reasons+=("Groups without server blocks: ${missing_groups[*]}")
    fi
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