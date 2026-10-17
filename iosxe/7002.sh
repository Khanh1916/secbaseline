#!/bin/bash

# Cisco IOS-XE Configuration Banner Login Validation Script
# Commercial Software Compatible
# 
# Purpose: Check if banner login is configured
# Input: Configuration file path as argument
# Output: PASS or FAILED
# 
# Usage: ./banner_check.sh <config_file>
# Example: ./banner_check.sh running-config.txt
#
# Requirements:
# - Configuration file must be readable
# - Script expects standard Cisco IOS-XE configuration format
#
# Return Codes:
# 0 = PASS (banner login configured)
# 1 = FAILED (no banner login found)

# Function to validate banner login configuration
check_banner_login() {
    local config_file="$1"
    
    # Look for 'banner login' command in config
    banner_line=$(grep -i "^banner login " "$config_file" 2>/dev/null)
    
    # Check if banner login line exists
    if [ -z "$banner_line" ]; then
        echo "FAILED"
        return 1
    else
        echo "PASS"
        return 0
    fi
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
    
    # Perform banner login validation
    check_banner_login "$config_file"
    exit $?
}

# Execute main function with all arguments
main "$@"