#!/bin/bash

# DESCRIPTION:
# This script validates Juniper device syslog configuration to ensure
# logging is sent to SIEM server with specified IP and minimum info level.
# Port is optional, defaults to 514.
#
# VALIDATION LOGIC:
# 1. Check if configuration file exists and is accessible
# 2. Validate SIEM host configuration with specified IP
# 3. Verify logging level meets minimum requirements
# 4. Check port configuration matches specified or default port
#
# STRICT VALIDATION REQUIREMENTS:
# - Configure syslog sending to SIEM IP (must provide exact SIEM IP & Port if specified)
# - Port is optional, defaults to 514 when not declared
# - Must have syslog host configuration with corresponding IP and port for specified SIEM
# - Logging level must be any of: info, notice, warning, error, critical, alert, emergency
#
# SIEM LOGGING REQUIREMENTS:
# [1] SIEM HOST CONFIGURATION
#     * Must have syslog host configuration with specified SIEM IP
#     * Validates: set system syslog host <siem_ip> any info
#
# [2] LOGGING LEVEL REQUIREMENT
#     * Minimum logging level must be "info" or higher
#     * Accepts: info, notice, warning, error, critical, alert, emergency
#     * Validates: set system syslog host <siem_ip> any info (or higher)
#
# [3] PORT CONFIGURATION
#     * If siem_port = 514 (default): PASS with or without explicit port line
#     * If siem_port != 514: MUST have corresponding port line
#     * Validates: set system syslog host <siem_ip> port <port>
#
# SAMPLE CONFIGURATION:
# set system syslog host 10.255.100.30 any info
# set system syslog host 10.255.100.30 source-address 10.255.100.7
# set system syslog host 10.255.100.50 any warning
# set system syslog host 10.255.100.50 port 1514
# set system syslog source-address 10.255.100.7
#
# USAGE:
# ./8013.sh <config_file> <siem_ip> [siem_port]
#
# PARAMETERS:
# config_file  - Junos configuration file (required)
# siem_ip      - SIEM server IP address (required)
# siem_port    - SIEM server port (optional, default: 514)
#
# EXIT CODES:
# 0 - PASS: Must have syslog host configuration with corresponding IP and port for specified SIEM, logging level any of info/notice/warning/error/critical/alert/emergency
# 1 - FAILED: Missing or incorrect logging configuration

SIEM_SERVERS=(
    "192.168.1.100:514"
    "192.168.100.104:514"
    # Add more SIEM servers as needed
)

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
    echo "FAILED"
    exit 1
fi

# Check passed
echo "PASS"
exit 0