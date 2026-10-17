#!/bin/bash

# DESCRIPTION:
# This script validates Cisco NX-OS configuration files to ensure proper
# SIEM logging configuration is enabled to send logs to specified SIEM servers.
#
# VALIDATION CRITERIA:
# - Must have "logging server <SIEM-IP> ... port <SIEM-PORT>" configuration
# - SIEM IP and PORT must match the allowed list defined in script variables
# - Returns PASS if at least one valid SIEM logging is configured, FAIL otherwise
#
# CONFIGURATION:
# Edit the ALLOWED_SIEM_SERVERS array below to specify valid SIEM IP:PORT pairs
#
# USAGE:
# ./10013.sh <config_file>
#
# EXAMPLES:
# ./10013.sh router-config.txt
# ./10013.sh /path/to/cisco-config.cfg
#
# SAMPLE CONFIGURATION:
# logging server 192.168.89.104 5 port 1514 use-vrf default facility syslog
# logging server 192.168.89.104 5 use-vrf default facility syslog (defaults to port 514)
# logging server 10.1.1.100 port 514 facility local0
# logging server 172.16.10.50 (defaults to port 514)
# logging timestamp milliseconds
# logging origin-id hostname
#
# EXIT CODES:
# 0 - PASS: SIEM logging is properly configured
# 1 - FAIL: SIEM logging is not configured
# 2 - ERROR: File not found or invalid arguments
#
# REQUIREMENTS:
# - Bash 4.0 or higher
# - Read access to configuration files
# - grep utilities (standard on most Unix/Linux systems)

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

# =============================================================================
# CONFIGURATION: Define allowed SIEM servers (IP:PORT pairs)
# Add or modify the SIEM server IP:PORT combinations that are allowed
# =============================================================================
ALLOWED_SIEM_SERVERS=(
    "192.168.89.104:1514"
    "192.168.89.104:514"     # Same IP with different ports
    "192.168.89.105:1514" 
    "10.1.1.100:514"
    "172.16.10.50:514"       # Default port 514
    # Add more IP:PORT pairs as needed
    # Note: If no port is specified in config, default port 514 is used
)

# Function to extract IP and PORT from logging server line
extract_ip_port_from_logging() {
    local line="$1"
    
    # Extract IP (first non-space field after "logging server")
    local ip=$(echo "$line" | awk '{
        for (i=1; i<=NF; i++) {
            if (tolower($i) == "server" && i < NF) {
                print $(i+1)
                break
            }
        }
    }')
    
    # Extract PORT (first number field after "port")
    local port=$(echo "$line" | awk '{
        for (i=1; i<=NF; i++) {
            if (tolower($i) == "port" && i < NF) {
                print $(i+1)
                break
            }
        }
    }')
    
    # If no port specified, use default port 514
    if [ -z "$port" ]; then
        port="514"
    fi
    
    if [ -n "$ip" ]; then
        echo "${ip}:${port}"
    fi
}

# Function to check if IP:PORT pair is in allowed list
is_allowed_siem_server() {
    local ip_port="$1"
    
    for allowed in "${ALLOWED_SIEM_SERVERS[@]}"; do
        if [ "$ip_port" = "$allowed" ]; then
            return 0  # Found in allowed list
        fi
    done
    
    return 1  # Not found in allowed list
}

# Function to check SIEM logging server configuration
check_siem_logging() {
    # Find all logging server lines (with or without explicit port)
    local logging_lines=$(grep -i "^logging[[:space:]]\+server[[:space:]]\+[^[:space:]]\+" "$CONFIG_FILE")
    
    if [ -z "$logging_lines" ]; then
        echo "NO_LOGGING_SERVERS_FOUND"
        return
    fi
    
    # Check each logging server line
    local found_valid_siem=false
    
    while IFS= read -r line; do
        # Extract IP:PORT from this line (PORT defaults to 514 if not specified)
        local ip_port=$(extract_ip_port_from_logging "$line")
        
        if [ -n "$ip_port" ]; then
            # Check if this IP:PORT is in allowed list
            if is_allowed_siem_server "$ip_port"; then
                found_valid_siem=true
                break
            fi
        fi
    done <<< "$logging_lines"
    
    if [ "$found_valid_siem" = true ]; then
        echo "VALID_SIEM_LOGGING_FOUND"
    else
        echo "NO_VALID_SIEM_LOGGING_FOUND"
    fi
}

# Initialize validation status
failed=false
failure_reasons=()

# Check SIEM logging configuration
siem_logging_status=$(check_siem_logging)
case "$siem_logging_status" in
    "NO_LOGGING_SERVERS_FOUND")
        failed=true
        failure_reasons+=("No logging server configuration found")
        ;;
    "NO_VALID_SIEM_LOGGING_FOUND")
        failed=true
        failure_reasons+=("No valid SIEM logging server found (IP:PORT not in allowed list)")
        ;;
    "VALID_SIEM_LOGGING_FOUND")
        # Valid SIEM logging found - this is good
        ;;
esac

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