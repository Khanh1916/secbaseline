#!/bin/bash

# Cisco IOS-XE Configuration Centralized Logging Validation Script
# Commercial Software Compatible - Version 2.0
# 
# Purpose: Validate centralized logging configuration for security monitoring and compliance
# Ensures proper log forwarding to configured SIEM servers for audit and analysis
# Input: Configuration file path as argument
# Output: PASS or FAIL
# 
# Usage: ./7013.sh <config_file>
# Example: ./7013.sh running-config.txt
#
# Requirements:
# - Configuration file must be readable
# - Script expects standard Cisco IOS-XE configuration format
# - Supports running-config and startup-config files
#
# Centralized Logging Validation Rules:
# 
# 1. SIEM Host Configuration:
#    - Must have: "logging host <siem_server>" for at least one configured SIEM
#    - Port validation: if port != 514, must have explicit "port <port_number>"
#    - If port = 514 (default): PASS with or without explicit port configuration
#    - Validates against pre-configured SIEM server list
#    - Essential for centralized security monitoring and compliance
#
# Security and Operational Benefits:
# - Centralized log collection for security event correlation
# - Persistent log storage beyond device memory limitations
# - Real-time security monitoring and alerting capabilities
# - Compliance with audit and forensic investigation requirements
# - Protection against log tampering on local device
# - Simplified log management across network infrastructure
#
# Return Codes:
# 0 = PASS (centralized logging to at least one SIEM server configured)
# 1 = FAIL (missing logging host configuration for configured SIEM servers)
# 2 = Invalid input or file access error

# SIEM SERVERS CONFIGURATION
SIEM_SERVERS=(
    "192.168.89.10:1514"
    "192.168.100.104"
    # Add more SIEM servers as needed
)

# Override with CHECKLIST_SIEM_SERVERS="ip[:port] ip[:port]" (space- or comma-separated).
if [ -n "${CHECKLIST_SIEM_SERVERS:-}" ]; then
    IFS=', ' read -r -a SIEM_SERVERS <<< "$CHECKLIST_SIEM_SERVERS"
fi

config_file="$1"

# Function to display usage
show_usage() {
    echo "Usage: $0 <config_file>"
    echo ""
    echo "Parameters:"
    echo "  config_file  - Cisco IOS-XE configuration file (required)"
    echo ""
    echo "Configured SIEM servers:"
    for server in "${SIEM_SERVERS[@]}"; do
        echo "  - $server"
    done
}

# Check input parameter and file existence
if [[ -z "$config_file" ]]; then
    echo "FAIL"
    exit 1
    show_usage >&2
    exit 1
fi

if [[ ! -f "$config_file" ]]; then
    echo "FAIL"
    exit 1
fi

if [[ ! -r "$config_file" ]]; then
    echo "FAIL"
    exit 1
fi

# Function to check if logging host is configured for a specific SIEM server
check_siem_logging() {
    local siem_ip="$1"
    local siem_port="$2"
    
    # Check for logging host configuration for this SIEM IP
    if ! grep -Ei "^\s*logging host\s+$siem_ip(\s|$)" "$config_file" >/dev/null; then
        return 1
    fi
    
    # Check port configuration
    local port_line=$(grep -Ei "^\s*logging host\s+$siem_ip.*port\s+[0-9]+" "$config_file")
    
    if [[ -n "$port_line" ]]; then
        # Port is explicitly configured - extract the configured port
        local configured_port=$(echo "$port_line" | sed -E 's/.*port\s+([0-9]+).*/\1/i')
        
        # The configured port must match the expected port
        if [[ "$configured_port" == "$siem_port" ]]; then
            return 0
        else
            # Port mismatch
            return 1
        fi
    else
        # No explicit port configuration found
        # This is only acceptable if we're expecting the default port 514
        if [[ "$siem_port" == "514" ]]; then
            return 0
        else
            # Non-default port expected but no port configuration found
            return 1
        fi
    fi
}

# Main validation logic - check all SIEM servers
check_all_siem_logging() {
    local found_valid_siem=false
    
    for server in "${SIEM_SERVERS[@]}"; do
        # Skip empty lines and comments
        if [[ -z "$server" || "$server" =~ ^[[:space:]]*# ]]; then
            continue
        fi
        
        # Parse IP and port from server string
        local siem_ip=$(echo "$server" | cut -d':' -f1)
        local siem_port=$(echo "$server" | cut -d':' -f2)
        
        # Default port to 514 if not specified or malformed
        if [[ -z "$siem_port" || ! "$siem_port" =~ ^[0-9]+$ ]]; then
            siem_port="514"
        fi
        
        # Check this SIEM server
        if check_siem_logging "$siem_ip" "$siem_port"; then
            found_valid_siem=true
            break  # Found at least one valid SIEM configuration
        fi
    done
    
    if [[ "$found_valid_siem" == true ]]; then
        return 0
    else
        return 1
    fi
}

# Execute main check
if check_all_siem_logging; then
    echo "PASS"
    exit 0
else
    echo "FAIL"
    exit 1
fi