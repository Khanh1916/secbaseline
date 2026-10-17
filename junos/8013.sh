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
# 1 - FAIL: Missing or incorrect logging configuration

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
if [ $# -ne 1 ] || [ ! -r "$1" ]; then
    echo "Usage: $0 <readable-junos-config>" >&2
    echo "FAIL"
    exit 1
fi

CONFIG_FILE="$1"
LEVELS="info|notice|warning|error|critical|alert|emergency"

# Function to check logging configuration to SIEM servers (Junos set format:
#   set system syslog host <ip> any <level>
#   set system syslog host <ip> port <port>)
check_siem_logging() {
    for siem_server in "${SIEM_SERVERS[@]}"; do
        local siem_ip="${siem_server%%:*}"
        local siem_port="${siem_server#*:}"
        [ "$siem_port" = "$siem_server" ] && siem_port="514"
        local ip_re="${siem_ip//./\.}"

        # The host must receive messages at info level or higher
        grep -qE "^set system syslog host ${ip_re} [a-z-]+ (${LEVELS})([[:space:]]|$)" "$CONFIG_FILE" || continue

        # Port: an explicit port line must match; without one Junos uses 514
        local port_line
        port_line=$(grep -E "^set system syslog host ${ip_re} port [0-9]+" "$CONFIG_FILE" | awk '{print $NF}' | head -n 1)
        if [ -n "$port_line" ]; then
            [ "$port_line" = "$siem_port" ] && return 0
        elif [ "$siem_port" = "514" ]; then
            return 0
        fi
    done
    return 1
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