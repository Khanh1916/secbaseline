#!/bin/bash

# Cisco IOS-XE Configuration Hostname Validation Script
# Commercial Software Compatible
# 
# Purpose: Check if device hostname is configured (not default Switch/Router)
# Input: Configuration file path as argument
# Output: PASS or FAILED
# 
# Usage: ./hostname_check.sh <config_file>
# Example: ./hostname_check.sh running-config.txt
#
# Requirements:
# - Configuration file must be readable
# - Script expects standard Cisco IOS-XE configuration format
#
# Return Codes:
# 0 = PASS (hostname configured properly)
# 1 = FAILED (default hostname or no hostname found)

# Function to validate hostname configuration
check_hostname() {
    local config_file="$1"
    
    # Extract hostname from configuration file
    # Look for 'hostname' command in config
    hostname_line=$(grep -i "^hostname " "$config_file" 2>/dev/null)
    
    # Check if hostname line exists
    if [ -z "$hostname_line" ]; then
        echo "FAILED"
        return 1
    fi
    
    # Extract hostname value (second field) and trim whitespace
    hostname_value=$(echo "$hostname_line" | awk '{print $2}' | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    # Debug: Display intermediate results
    # echo "DEBUG: Found hostname line: $hostname_line" >&2
    # echo "DEBUG: Extracted hostname value: '$hostname_value'" >&2
    
    # Check against default hostnames (exact match)
    # Check for: Switch, Router, switch, router
    case "$hostname_value" in
        "Switch"|"Router"|"switch"|"router")
            echo "FAILED"
            return 1
            ;;
        *)
            echo "PASS"
            return 0
            ;;
    esac
}

# Main execution
main() {
    # Validate input parameter
    if [ $# -ne 1 ]; then
        echo "FAILED"
        exit 1
    fi
    
    config_file="$1"
    
    # Check if file exists and is readable
    if [ ! -f "$config_file" ] || [ ! -r "$config_file" ]; then
        echo "FAILED"
        exit 1
    fi
    
    # Perform hostname validation
    check_hostname "$config_file"
    exit $?
}

# Execute main function with all arguments
main "$@"