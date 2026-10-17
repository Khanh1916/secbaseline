#!/bin/bash

# DESCRIPTION:
# This script validates Cisco IOS XR configuration files to ensure proper
# SNMP security configuration. SNMP must be properly secured to prevent
# unauthorized access and data exposure.
#
# VALIDATION CRITERIA:
# FORBIDDEN CONFIGURATIONS:
# - No "snmp-server ... public ..."
# - No "snmp-server ... private ..."
# - No "snmp-server ... noauth ..."
# - No "snmp-server ... RW ..."
#
# REQUIRED CONFIGURATIONS:
# - ACL must limit SNMP source IPs
# - ACL must be used with "snmp-server group" and "snmp-server community"
# - "snmp-server user" must have auth-sha and priv-aes configuration
# - "snmp-server host" must limit IP addresses OR "snmp-server vrf" with host configurations
# - "snmp-server traps snmp" must be enabled
#
# USAGE:
# ./9010.sh <config_file>
#
# EXAMPLES:
# ./9010.sh router-config.txt
# ./9010.sh /path/to/cisco-config.cfg
#
# EXIT CODES:
# 0 - PASS: Configuration meets SNMP security requirements
# 1 - FAIL: Configuration does not meet security requirements
# 2 - ERROR: File not found or invalid arguments
#
# REQUIREMENTS:
# - Bash 4.0 or higher
# - Read access to configuration files
# - grep, sed, awk utilities (standard on most Unix/Linux systems)
#
# EXAMPLE SECURE CONFIGURATION:
# ipv4 access-list ACL-SNMP-IPv4
#  10 permit ipv4 host 192.168.89.104 any
#  20 permit ipv4 192.168.1.0/24 any
# !
# snmp-server community c0mun1tyStr RO IPv4 ACL-SNMP-IPv4
# snmp-server group SNMPGRPv3 V3 PRiv ipv4 ACL-SNMP-IPv4
# snmp-server user snmpviewer SNMPGRPv3 v3 auth sha encrypted ... priv aes encrypted ...
# snmp-server host 192.168.1.100 traps version 2c c0mun1tyStr udp-port 161
# OR
# snmp-server vrf mgmt
#  host 192.168.89.104 traps version 2c c0mun1tyStr udp-port 161
#  host 192.168.89.104 traps version 3 auth encrypted encryption-aes 06361D705A6E394D1624
# !
# snmp-server traps snmp

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

# Function to check forbidden SNMP configurations
check_forbidden_snmp() {
    # Check for public keyword anywhere in snmp-server lines
    if grep -qi "^[[:space:]]*snmp-server.*[[:space:]]\+public\b" "$CONFIG_FILE"; then
        return 1
    fi
    
    # Check for private keyword anywhere in snmp-server lines
    if grep -qi "^[[:space:]]*snmp-server.*[[:space:]]\+private\b" "$CONFIG_FILE"; then
        return 1
    fi
    
    # Check for noauth keyword anywhere in snmp-server lines
    if grep -qi "^[[:space:]]*snmp-server.*[[:space:]]\+noauth\b" "$CONFIG_FILE"; then
        return 1
    fi
    
    # Check for RW keyword anywhere in snmp-server lines
    if grep -qi "^[[:space:]]*snmp-server.*[[:space:]]\+RW\b" "$CONFIG_FILE"; then
        return 1
    fi
    
    return 0
}

# Function to check ACL configuration for SNMP
check_snmp_acl() {
    # Step 1: Get ALL snmp-server community and group lines
    local all_snmp_lines=$(grep -i "^[[:space:]]*snmp-server[[:space:]]\+\(community\|group\)" "$CONFIG_FILE")
    
    if [ -z "$all_snmp_lines" ]; then
        return 1
    fi
    
    # Step 2: Check each line has ACL
    local lines_without_acl=0
    local acl_names=""
    
    while IFS= read -r line; do
        if echo "$line" | grep -qi "\bipv4[[:space:]]\+[A-Za-z0-9_-]\+"; then
            # Extract ACL name for later validation
            local acl_name=$(echo "$line" | grep -oi "\bipv4[[:space:]]\+[A-Za-z0-9_-]\+" | sed 's/^[Ii][Pp][Vv]4[[:space:]]\+//')
            if [ -n "$acl_name" ]; then
                acl_names="$acl_names $acl_name"
            fi
        else
            lines_without_acl=$((lines_without_acl + 1))
        fi
    done <<< "$all_snmp_lines"
    
    # If any line lacks ACL, fail immediately
    if [ "$lines_without_acl" -gt 0 ]; then
        return 1
    fi
    
    # Step 3: Validate that referenced ACLs exist
    if [ -z "$acl_names" ]; then
        return 1
    fi
    
    for acl_name in $acl_names; do
        if [ -n "$acl_name" ]; then
            # Check if ACL exists in configuration
            if ! grep -q "^[[:space:]]*ipv4[[:space:]]\+access-list[[:space:]]\+$acl_name[[:space:]]*$" "$CONFIG_FILE"; then
                return 1
            fi
            
            # Extract and validate ACL content
            local acl_content=$(sed -n "/^[[:space:]]*ipv4[[:space:]]\+access-list[[:space:]]\+$acl_name[[:space:]]*$/,/^![[:space:]]*$/p" "$CONFIG_FILE" | \
                               head -n -1 | tail -n +2)
            
            if [ -z "$acl_content" ]; then
                return 1
            fi
            
            # Check for permit rules
            local permit_rules=$(echo "$acl_content" | grep "^[[:space:]]*[0-9]\+[[:space:]]\+permit")
            
            if [ -z "$permit_rules" ]; then
                return 1
            fi
            
            # Check for overly permissive rules
            if echo "$permit_rules" | grep -qi "permit[[:space:]]\+ipv4[[:space:]]\+any[[:space:]]\+any"; then
                return 1
            fi
        fi
    done
    
    return 0
}

# Function to check SNMPv3 user authentication and encryption
check_snmpv3_security() {
    # Get all snmp-server user configurations
    local snmp_users=$(grep -i "^[[:space:]]*snmp-server[[:space:]]\+user" "$CONFIG_FILE")
    
    if [ -z "$snmp_users" ]; then
        return 1
    fi
    
    # Check each user line for required security
    while IFS= read -r user_line; do
        # Must have both auth sha and priv aes
        if ! echo "$user_line" | grep -qi "auth[[:space:]]\+sha"; then
            return 1
        fi
        
        if ! echo "$user_line" | grep -qi "priv[[:space:]]\+aes"; then
            return 1
        fi
    done <<< "$snmp_users"
    
    return 0
}

# Function to check SNMP host restrictions
check_snmp_host() {
    # Method 1: Check for global snmp-server host configurations
    local global_snmp_hosts=$(grep -i "^[[:space:]]*snmp-server[[:space:]]\+host" "$CONFIG_FILE")
    
    # Method 2: Check for snmp-server vrf block with host configurations
    local vrf_snmp_content=$(sed -n '/^[[:space:]]*snmp-server[[:space:]]\+vrf[[:space:]]\+/,/^![[:space:]]*$/p' "$CONFIG_FILE")
    local vrf_hosts=""
    if [ -n "$vrf_snmp_content" ]; then
        vrf_hosts=$(echo "$vrf_snmp_content" | grep -i "^[[:space:]]\+host[[:space:]]\+")
    fi
    
    # Must have at least one method configured
    if [ -z "$global_snmp_hosts" ] && [ -z "$vrf_hosts" ]; then
        return 1  # No SNMP hosts configured in either method
    fi
    
    # Validate global hosts if present
    if [ -n "$global_snmp_hosts" ]; then
        while IFS= read -r host_line; do
            # Must have specific IP address (not any or wildcard)
            if ! echo "$host_line" | grep -q "[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+"; then
                return 1
            fi
        done <<< "$global_snmp_hosts"
    fi
    
    # Validate VRF hosts if present
    if [ -n "$vrf_hosts" ]; then
        while IFS= read -r host_line; do
            # Must have specific IP address (not any or wildcard)
            if ! echo "$host_line" | grep -q "[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+"; then
                return 1
            fi
        done <<< "$vrf_hosts"
    fi
    
    return 0
}

# Function to check SNMP traps configuration
check_snmp_traps() {
    # Check for snmp-server traps snmp
    if grep -qi "^[[:space:]]*snmp-server[[:space:]]\+traps[[:space:]]\+snmp" "$CONFIG_FILE"; then
        return 0
    fi
    
    return 1
}

# Main validation logic
# Step 1: Check for forbidden configurations
check_forbidden_snmp
if [ $? -ne 0 ]; then
    echo "FAIL"
    # Uncomment below line for detailed debugging:
    # echo "FAIL: Forbidden SNMP keywords found (public/private/noauth/RW)"
    exit 1
fi

# Step 2: Check ACL configuration
check_snmp_acl
if [ $? -ne 0 ]; then
    echo "FAIL"
    # Uncomment below line for detailed debugging:
    # echo "FAIL: Missing or improper ACL configuration for SNMP"
    exit 1
fi

# Step 3: Check SNMPv3 security
check_snmpv3_security
if [ $? -ne 0 ]; then
    echo "FAIL"
    # Uncomment below line for detailed debugging:
    # echo "FAIL: Missing or improper SNMPv3 authentication/encryption"
    exit 1
fi

# Step 4: Check SNMP host restrictions
check_snmp_host
if [ $? -ne 0 ]; then
    echo "FAIL"
    # Uncomment below line for detailed debugging:
    # echo "FAIL: Missing or improper SNMP host IP restrictions"
    exit 1
fi

# Step 5: Check SNMP traps
check_snmp_traps
if [ $? -ne 0 ]; then
    echo "FAIL"
    # Uncomment below line for detailed debugging:
    # echo "FAIL: SNMP traps not enabled"
    exit 1
fi

# All checks passed
echo "PASS"
exit 0