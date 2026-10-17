#!/bin/bash

# DESCRIPTION:
# This script validates Cisco IOS XR configuration files to ensure proper
# timezone and NTP server configuration for accurate time synchronization.
# Network devices must be configured with correct timezone and NTP sources
# to maintain accurate timestamps for logging, debugging, and security purposes.
#
# VALIDATION CRITERIA:
# TIMEZONE REQUIREMENT:
# - Must have exact configuration: "clock timezone areaname Asia/Saigon"
# - Configuration is case-sensitive and format must be exact
# 
# NTP SERVER REQUIREMENT:
# - Must have "ntp" section in configuration
# - Must contain "server" configuration with IP address
# - Must contain "source" configuration specifying interface
# - Both server and source must be within the ntp block
#
# USAGE:
# ./9009.sh <config_file>
#
# EXAMPLES:
# ./9009.sh router-config.txt
# ./9009.sh /path/to/cisco-config.cfg
#
# EXIT CODES:
# 0 - PASS: Configuration meets timezone and NTP requirements
# 1 - FAIL: Configuration does not meet requirements
# 2 - ERROR: File not found or invalid arguments
#
# REQUIREMENTS:
# - Bash 4.0 or higher
# - Read access to configuration files
# - grep, sed, awk utilities (standard on most Unix/Linux systems)
#
# EXAMPLE VALID CONFIGURATION:
# clock timezone areaname Asia/Saigon
# !
# ntp
#  server vrf mgmt 115.165.161.155
#  source vrf mgmt MgmtEth0/RP0/CPU0/0
# !

# Check arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 <config_file>"
    # echo ""
    # echo "This script validates Cisco IOS XR timezone and NTP configuration."
    # echo ""
    # echo "Required configuration:"
    # echo "  - clock timezone areaname Asia/Saigon"
    # echo "  - ntp server with IP address"
    # echo "  - ntp source interface"
    # echo ""
    # echo "Example:"
    # echo "  $0 router-config.txt"
    exit 1
fi

CONFIG_FILE="$1"

# Check file exists and is readable
if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: File not found: $CONFIG_FILE"
    exit 1
fi

if [ ! -r "$CONFIG_FILE" ]; then
    echo "ERROR: Cannot read file: $CONFIG_FILE"
    exit 1
fi

# Expected time zone name; override with CHECKLIST_TZ_NAME (e.g. Europe/Berlin).
TZ_NAME="${CHECKLIST_TZ_NAME:-Asia/Saigon}"

# Function to check timezone configuration
check_timezone_config() {
    # Look for exact timezone configuration
    if grep -q "^[[:space:]]*clock[[:space:]]\+timezone[[:space:]]\+areaname[[:space:]]\+${TZ_NAME}[[:space:]]*$" "$CONFIG_FILE"; then
        return 0
    else
        return 1
    fi
}

# Function to check NTP configuration
check_ntp_config() {
    # Extract NTP block from configuration - must start at beginning of line
    local ntp_content=$(sed -n '/^ntp[[:space:]]*$/,/^![[:space:]]*$/p' "$CONFIG_FILE")
    
    if [ -z "$ntp_content" ]; then
        return 1
    fi
    
    # Check for server configuration in NTP block
    if ! echo "$ntp_content" | grep -q "^[[:space:]]\+server[[:space:]]\+"; then
        return 1
    fi
    
    # Check for source configuration in NTP block
    if ! echo "$ntp_content" | grep -q "^[[:space:]]\+source[[:space:]]\+"; then
        return 1
    fi
    
    # Additional validation - check if server has IP address
    local server_line=$(echo "$ntp_content" | grep "^[[:space:]]\+server[[:space:]]\+")
    if ! echo "$server_line" | grep -q "[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+"; then
        return 1
    fi
    
    # Additional validation - check if source has interface
    local source_line=$(echo "$ntp_content" | grep "^[[:space:]]\+source[[:space:]]\+")
    if ! echo "$source_line" | grep -qE "(Eth|GigabitEthernet|TenGigE|FastEthernet|MgmtEth|Loopback)"; then
        return 1
    fi
    
    return 0
}

# Main validation logic
# Step 1: Check timezone configuration
check_timezone_config
TIMEZONE_RESULT=$?

if [ "$TIMEZONE_RESULT" -ne 0 ]; then
    echo "FAIL"
    # Uncomment below line for detailed debugging:
    # echo "FAIL: Clock timezone configuration missing or incorrect"
    # echo "Required: clock timezone areaname Asia/Saigon"
    exit 1
fi

# Step 2: Check NTP configuration
check_ntp_config
NTP_RESULT=$?

if [ "$NTP_RESULT" -ne 0 ]; then
    echo "FAIL"
    # Uncomment below line for detailed debugging:
    # echo "FAIL: NTP server and source configuration missing or incorrect"
    # echo "Required: ntp block with server and source configurations"
    exit 1
fi

# All checks passed
echo "PASS"
exit 0