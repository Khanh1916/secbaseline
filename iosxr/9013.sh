#!/bin/bash

# DESCRIPTION:
# This script validates Cisco IOS XR configuration files to ensure proper
# syslog configuration for sending logs to SIEM servers. The script checks
# if any of the specified SIEM IP addresses are configured for logging.
#
# VALIDATION CRITERIA:
# REQUIRED CONFIGURATIONS:
# - Must have logging configuration to at least one specified SIEM IP:PORT
# - Default port is 514 if not specified
# - Support multiple SIEM IP:PORT combinations
#
# USAGE:
# ./9013.sh <config_file>
#
# CONFIGURATION:
# Edit the SIEM_SERVERS array below to specify your SIEM servers.
# Format: "IP:PORT" or "IP" (default port 514)
#
# EXAMPLES:
# ./9013.sh router-config.txt
#
# EXIT CODES:
# 0 - PASS: Configuration has logging to at least one specified SIEM server
# 1 - FAIL: Configuration does not have logging to any SIEM server
# 2 - ERROR: File not found or invalid arguments
#
# REQUIREMENTS:
# - Bash 4.0 or higher
# - Read access to configuration files
# - grep utilities (standard on most Unix/Linux systems)
#
# EXAMPLE VALID CONFIGURATION:
# logging 192.168.1.100 vrf default port 514
# logging 192.168.100.104 vrf mgmt port default

# SIEM SERVER CONFIGURATION
# Add your SIEM servers here in format "IP:PORT" or "IP" (default port 514)
SIEM_SERVERS=(
    "192.168.1.100:514"
    "192.168.100.104:514"
    # Add more SIEM servers as needed
)

# Override with CHECKLIST_SIEM_SERVERS="ip[:port] ip[:port]" (space- or comma-separated).
if [ -n "${CHECKLIST_SIEM_SERVERS:-}" ]; then
    IFS=', ' read -r -a SIEM_SERVERS <<< "$CHECKLIST_SIEM_SERVERS"
fi

# Check arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 <config_file>"
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

# Function to check logging configuration to SIEM servers
check_siem_logging() {
    # Check each SIEM server in the array
    for siem_server in "${SIEM_SERVERS[@]}"; do
        # Parse IP and PORT from server entry
        local siem_ip=$(echo "$siem_server" | cut -d: -f1)
        local siem_port=$(echo "$siem_server" | cut -d: -f2)
        
        # If no port specified, use default 514
        if [ "$siem_ip" = "$siem_port" ]; then
            siem_port="514"
        fi
        
        # Check if there's a logging configuration for this SIEM IP
        local logging_lines=$(grep "^logging[[:space:]]\+$siem_ip\b" "$CONFIG_FILE")
        
        if [ -n "$logging_lines" ]; then
            # Found logging for this IP, now check port
            if echo "$logging_lines" | grep -q "port[[:space:]]\+$siem_port\b"; then
                return 0  # Found exact port match
            elif [ "$siem_port" = "514" ] && echo "$logging_lines" | grep -q "port[[:space:]]\+default\b"; then
                return 0  # Found default port (514) match
            elif ! echo "$logging_lines" | grep -q "port[[:space:]]\+"; then
                # No port specified in config, assume default 514
                if [ "$siem_port" = "514" ]; then
                    return 0  # Default port match
                fi
            fi
        fi
    done
    
    return 1  # No SIEM logging configuration found
}

# Main validation logic
check_siem_logging
if [ $? -ne 0 ]; then
    echo "FAIL"
    exit 1
fi

# Check passed
echo "PASS"
exit 0