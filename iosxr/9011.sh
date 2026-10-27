#!/bin/bash

# DESCRIPTION:
# This script validates Cisco IOS XR configuration files to ensure proper
# SSH security configuration. Only secure SSH version 2 should be enabled
# and only SSH transport should be allowed for remote access.
#
# VALIDATION CRITERIA:
# REQUIRED CONFIGURATIONS:
# - Must have "ssh server v2" only (no v1)
# - Must have "transport input ssh" in all "line default" configurations
# - Must have "transport input ssh" in all "line template" configurations
#
# FORBIDDEN CONFIGURATIONS:
# - No "ssh server v1"
# - No other transport protocols in line configurations
#
# USAGE:
# ./9011.sh <config_file>
#
# EXAMPLES:
# ./9011.sh router-config.txt
# ./9011.sh /path/to/cisco-config.cfg
#
# EXIT CODES:
# 0 - PASS: Configuration meets SSH security requirements
# 1 - FAIL: Configuration does not meet security requirements
# 2 - ERROR: File not found or invalid arguments
#
# REQUIREMENTS:
# - Bash 4.0 or higher
# - Read access to configuration files
# - grep, sed utilities (standard on most Unix/Linux systems)
#
# EXAMPLE SECURE CONFIGURATION:
# ssh server logging
# ssh server v2
# !
# line default
#  transport input ssh
# !
# line template VTY-TEMP
#  transport input ssh
# !

# Check arguments
if [ $# -ne 1 ]; then
    echo "FAIL"
    exit 1
fi

CONFIG_FILE="$1"

# Check file exists and is readable
if [ ! -f "$CONFIG_FILE" ]; then
    echo "FAIL"
    exit 1
fi

if [ ! -r "$CONFIG_FILE" ]; then
    echo "FAIL"
    exit 1
fi

# Function to check SSH server version configuration
check_ssh_server_version() {
    # Must have ssh server v2
    if ! grep -qi "^[[:space:]]*ssh[[:space:]]\+server[[:space:]]\+v2[[:space:]]*$" "$CONFIG_FILE"; then
        return 1
    fi
    
    # Must not have ssh server v1
    if grep -qi "^[[:space:]]*ssh[[:space:]]\+server[[:space:]]\+v1\b" "$CONFIG_FILE"; then
        return 1
    fi
    
    return 0
}

# Function to check line default and template transport configuration
check_line_transport() {
    # Count line default configurations
    local line_default_count=$(grep -c "^[[:space:]]*line[[:space:]]\+default[[:space:]]*$" "$CONFIG_FILE")
    
    # Count line template configurations  
    local line_template_count=$(grep -c "^[[:space:]]*line[[:space:]]\+template[[:space:]]\+" "$CONFIG_FILE")
    
    # Total line configurations
    local total_line_count=$((line_default_count + line_template_count))
    
    # Count transport input ssh configurations
    local transport_ssh_count=$(grep -c "^[[:space:]]\+transport[[:space:]]\+input[[:space:]]\+ssh[[:space:]]*$" "$CONFIG_FILE")
    
    # Must have at least one line configuration
    if [ "$total_line_count" -eq 0 ]; then
        return 1
    fi
    
    # Number of lines must equal number of transport input ssh
    if [ "$total_line_count" -eq "$transport_ssh_count" ]; then
        return 0
    else
        return 1
    fi
}

# Main validation logic
# Step 1: Check SSH server version
check_ssh_server_version
if [ $? -ne 0 ]; then
    echo "FAIL"
    # Uncomment below line for detailed debugging:
    # echo "FAIL: Missing 'ssh server v2' or forbidden 'ssh server v1' found"
    exit 1
fi

# Step 2: Check line transport configurations
check_line_transport
if [ $? -ne 0 ]; then
    echo "FAIL"
    # Uncomment below line for detailed debugging:
    # echo "FAIL: Line count does not match transport input ssh count"
    exit 1
fi

# All checks passed
echo "PASS"
exit 0