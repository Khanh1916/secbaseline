#!/bin/bash

# DESCRIPTION:
# This script validates Cisco IOS XR configuration files to ensure proper
# access control configuration for device management access.
# Administrators should restrict IP/Subnet access to network device management
# to prevent unauthorized access and enhance security posture.
#
# VALIDATION CRITERIA:
# ACCESS-LIST BYPASS METHOD:
# - If ssh server has both ipv4 and ipv6 access-lists, can bypass MPP check
# - All "ssh server vrf" configurations must include both access-list parameters
# - Access-lists must restrict source IP (no "permit ipv4 any any" or "permit tcp any any")
# 
# MPP MANDATORY METHOD:
# - If ssh server vrf exists without complete access-lists, MPP is mandatory
# - Must have out-of-band vrf section matching ssh server vrf names
# - Must have "allow SSH peer" for ssh server vrf
# - Must have "allow NETCONF peer" for ssh server netconf vrf
# - Address cannot be 0.0.0.0, any, ::/0, /0, or :: (wildcards)
# Be aware that if MPP is disabled and a protocol is activated, all interfaces can pass traffic.
#
# # SAMPLE CONFIGURATIONS:
# ACCESS-LIST METHOD:
# ! # CONFIG ACL FOR VTY
# ipv4 access-list ACL-VTY-IN
#  10 permit ipv4 10.255.255.0/24 any
#  20 permit ipv4 host 192.168.1.100 any
#  1000 deny ipv4 any any log icmp-off
# ipv6 access-list ACL-VTY-IN
#  10 permit ipv6 2001:db8::/64 any
#  20 permit ipv6 2002:db8::/64 any
#  1000 deny any any log icmp-off
# !
# ! # APPLY ACL TO SSH SERVER
# ssh server vrf mgmt ipv4 access-list ACL-VTY-IN ipv6 access-list ACL-VTY-IN
# ssh server vrf default ipv4 access-list ACL-VTY-IN ipv6 access-list ACL-VTY-IN
# ssh server netconf vrf mgmt ipv4 access-list ACL-VTY-IN ipv6 access-list ACL-VTY-IN
# ssh server vrf mgmt ipv4 access-list ACL-VTY-IN ipv6 access-list ACL-VTY-IN
#
# MPP METHOD:
# control-plane
#  management-plane
#   inband
#    interface Loopback0
#     allow SSH peer
#      address ipv4 192.168.1.100
#     !
#     allow NETCONF peer
#      address ipv6 2001:db8::/64
#     !
#    !
#   !
#   out-of-band
#    vrf mgmt
#    interface MgmtEth0/RP0/CPU0/0
#     allow SSH peer
#      address ipv4 10.255.255.0/24
#      address ipv6 2001:db8::/64
#     !
# USAGE:
# ./9004.sh <config_file>
#
# EXAMPLES:
# ./9004.sh router-config.txt
# ./9004.sh /path/to/cisco-config.cfg
#
# EXIT CODES:
# 0 - PASS: Configuration meets access control requirements
# 1 - FAILED: Configuration does not meet requirements
# 2 - ERROR: File not found or invalid arguments
#
# REQUIREMENTS:
# - Bash 4.0 or higher
# - Read access to configuration files
# - grep, awk utilities (standard on most Unix/Linux systems)

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

# Check if ssh server has complete access-lists (both ipv4 and ipv6)
check_complete_access_lists() {
    # Get all ssh server vrf lines (both regular and netconf)
    local ssh_lines=$(grep -i "ssh server.*vrf" "$CONFIG_FILE")
    
    if [ -z "$ssh_lines" ]; then
        return 2  # No ssh server vrf found
    fi
    
    # Check each ssh server line - must have BOTH ipv4 and ipv6 access-lists
    while IFS= read -r line; do
        local has_ipv4_acl=false
        local has_ipv6_acl=false
        
        if echo "$line" | grep -qi "ipv4[[:space:]]\+access-list"; then
            has_ipv4_acl=true
        fi
        
        if echo "$line" | grep -qi "ipv6[[:space:]]\+access-list"; then
            has_ipv6_acl=true
        fi
        
        # EVERY ssh server line must have both ipv4 and ipv6 access-list to qualify for bypass
        if [ "$has_ipv4_acl" = false ] || [ "$has_ipv6_acl" = false ]; then
            return 1  # Incomplete access-lists, cannot bypass MPP
        fi
    done <<< "$ssh_lines"
    
    # Extract and validate all ACL names
    local acl_names=$(echo "$ssh_lines" | \
                     grep -o "access-list[[:space:]]\+[A-Za-z0-9_-]\+" | \
                     awk '{print $2}' | sort -u)
    
    if [ -z "$acl_names" ]; then
        return 1
    fi
    
    # Check each ACL content
    for acl_name in $acl_names; do
        # Extract ACL block
        local acl_lines=$(sed -n "/^[[:space:]]*ipv[46][[:space:]]\+access-list[[:space:]]\+$acl_name[[:space:]]*$/,/^[[:space:]]*!/p" "$CONFIG_FILE" | \
                         head -n -1 | tail -n +2)
        
        # Get permit rules only
        local acl_rules=$(echo "$acl_lines" | grep "^[[:space:]]*[0-9]\+[[:space:]]\+permit")
        
        # Check for dangerous permit statements
        if echo "$acl_rules" | grep -qi "permit[[:space:]]\+\(ipv[46]\|tcp\|ip\)[[:space:]]\+any[[:space:]]\+any"; then
            echo "FAILED"
            exit 1
        fi
    done
    
    return 0  # Complete and valid access-lists
}

# Check MPP method (mandatory when access-lists incomplete)
check_mpp_mandatory() {
    # Check for standalone allow SERVICE lines (forbidden)
    if grep -qi "^[[:space:]]*allow[[:space:]]\+\(HTTP\|NETCONF\|SNMP\|SSH\|TFTP\|Telnet\|XML\|all\)[[:space:]]*$" "$CONFIG_FILE"; then
        echo "FAILED"
        exit 1
    fi
    
    # Extract control-plane management-plane block
    local mpp_content=$(sed -n '/^[[:space:]]*control-plane[[:space:]]*$/,/^![[:space:]]*$/p' "$CONFIG_FILE" | \
                       sed -n '/^[[:space:]]*management-plane[[:space:]]*$/,/^![[:space:]]*$/p')
    
    # MPP block must exist when access-lists are incomplete
    if [ -z "$mpp_content" ]; then
        echo "FAILED"
        exit 1
    fi
    
    # Check for forbidden addresses in MPP block
    if echo "$mpp_content" | grep -qi "[[:space:]]\+address[[:space:]]\+ipv6[[:space:]]\+::[[:space:]]*$"; then
        echo "FAILED"
        exit 1
    fi
    
    if echo "$mpp_content" | grep -qi "[[:space:]]\+address[[:space:]]\+ipv6[[:space:]]\+::/0"; then
        echo "FAILED"
        exit 1
    fi
    
    if echo "$mpp_content" | grep -qi "[[:space:]]\+address[[:space:]]\+ipv4[[:space:]]\+0\.0\.0\.0/0"; then
        echo "FAILED"
        exit 1
    fi
    
    if echo "$mpp_content" | grep -qi "[[:space:]]\+address[[:space:]]\+ipv4[[:space:]]\+0\.0\.0\.0[[:space:]]*$"; then
        echo "FAILED"
        exit 1
    fi
    
    # Extract VRF names from ssh server commands
    local ssh_vrfs=$(grep -i "ssh server.*vrf\|ssh server netconf.*vrf" "$CONFIG_FILE" | \
                    grep -o "vrf[[:space:]]\+[A-Za-z0-9_-]\+" | \
                    awk '{print $2}' | sort -u)
    
    if [ -n "$ssh_vrfs" ]; then
        # Must have out-of-band section if non-default VRFs exist
        local has_non_default_vrf=false
        for vrf_check in $ssh_vrfs; do
            if [ "$vrf_check" != "default" ]; then
                has_non_default_vrf=true
                break
            fi
        done
        
        # Check if out-of-band section exists when non-default VRFs are present
        local has_out_of_band=false
        if echo "$mpp_content" | grep -qi "^[[:space:]]*out-of-band[[:space:]]*$"; then
            has_out_of_band=true
        fi
        
        # If we have non-default VRFs but no out-of-band section, FAIL
        if [ "$has_non_default_vrf" = true ] && [ "$has_out_of_band" = false ]; then
            echo "FAILED"
            exit 1
        fi
        
        # Check each VRF
        for vrf_name in $ssh_vrfs; do
            local vrf_content=""
            
            if [ "$vrf_name" = "default" ]; then
                # Default VRF uses inband section - check if inband exists
                if echo "$mpp_content" | grep -qi "^[[:space:]]*inband[[:space:]]*$"; then
                    # Extract inband block using "   !" (3 spaces) as end marker
                    vrf_content=$(echo "$mpp_content" | \
                                 sed -n '/^[[:space:]]*inband[[:space:]]*$/,/^   ![[:space:]]*$/p' | \
                                 head -n -1)
                    
                    if [ -z "$vrf_content" ]; then
                        echo "FAILED"
                        exit 1
                    fi
                else
                    echo "FAILED"
                    exit 1
                fi
            else
                # Non-default VRF uses out-of-band section
                if [ "$has_out_of_band" = false ]; then
                    echo "FAILED"
                    exit 1
                fi
                
                # Extract entire out-of-band block using "   !" (3 spaces) as end marker
                vrf_content=$(echo "$mpp_content" | \
                             sed -n '/^[[:space:]]*out-of-band[[:space:]]*$/,/^   ![[:space:]]*$/p' | \
                             head -n -1)
                
                if [ -z "$vrf_content" ]; then
                    echo "FAILED"
                    exit 1
                fi
            fi
            
            # Check required allow peer based on ssh server type
            local has_ssh_server=false
            local has_netconf_server=false
            
            # Check for regular ssh server vrf (NOT netconf)
            if grep -qi "ssh[[:space:]]\+server[[:space:]]\+vrf[[:space:]]\+${vrf_name}" "$CONFIG_FILE"; then
                regular_ssh_lines=$(grep -i "ssh[[:space:]]\+server[[:space:]]\+vrf[[:space:]]\+${vrf_name}" "$CONFIG_FILE" | grep -v -i "netconf")
                if [ -n "$regular_ssh_lines" ]; then
                    has_ssh_server=true
                fi
            fi
            
            # Check for ssh server netconf independently  
            if grep -qi "ssh[[:space:]]\+server[[:space:]]\+netconf[[:space:]]\+vrf[[:space:]]\+${vrf_name}" "$CONFIG_FILE" || \
               grep -qi "ssh.*server.*netconf.*vrf.*${vrf_name}" "$CONFIG_FILE"; then
                has_netconf_server=true
            fi
            
            # Validate required allow peers
            if [ "$has_ssh_server" = true ]; then
                if ! echo "$vrf_content" | grep -qi "allow[[:space:]]\+SSH[[:space:]]\+peer" && \
                   ! echo "$vrf_content" | grep -qi "allow.*SSH.*peer"; then
                    echo "FAILED"
                    exit 1
                fi
            fi
            
            if [ "$has_netconf_server" = true ]; then
                if ! echo "$vrf_content" | grep -qi "allow[[:space:]]\+NETCONF[[:space:]]\+peer" && \
                   ! echo "$vrf_content" | grep -qi "allow.*NETCONF.*peer"; then
                    echo "FAILED"
                    exit 1
                fi
            fi
        done
    fi
    
    return 0  # MPP validation passed
}

# Main validation logic

# Step 1: Check if ssh server vrf exists
if ! grep -qi "ssh server.*vrf\|ssh server netconf.*vrf" "$CONFIG_FILE"; then
    # No ssh server vrf, check basic MPP if exists
    mpp_exists=$(sed -n '/^[[:space:]]*control-plane[[:space:]]*$/,/^![[:space:]]*$/p' "$CONFIG_FILE" | \
                      sed -n '/^[[:space:]]*management-plane[[:space:]]*$/,/^![[:space:]]*$/p')
    
    if [ -n "$mpp_exists" ]; then
        # Basic MPP validation
        if echo "$mpp_exists" | grep -qi "[[:space:]]\+address[[:space:]]\+ipv6[[:space:]]\+::[[:space:]]*$"; then
            echo "FAILED"
            exit 1
        elif echo "$mpp_exists" | grep -qi "[[:space:]]\+address[[:space:]]\+ipv6[[:space:]]\+::/0"; then
            echo "FAILED"
            exit 1
        elif echo "$mpp_exists" | grep -qi "[[:space:]]\+address[[:space:]]\+ipv4[[:space:]]\+0\.0\.0\.0/0"; then
            echo "FAILED"
            exit 1
        elif echo "$mpp_exists" | grep -qi "[[:space:]]\+address[[:space:]]\+ipv4[[:space:]]\+0\.0\.0\.0[[:space:]]*$"; then
            echo "FAILED"
            exit 1
        fi
    fi
    
    echo "PASS"
    exit 0
fi

# Step 2: Try access-list bypass method
check_complete_access_lists
ACCESS_LIST_RESULT=$?

if [ "$ACCESS_LIST_RESULT" -eq 0 ]; then
    echo "PASS"  # Complete access-lists found, bypass MPP
    exit 0
fi

# Step 3: Access-lists incomplete, MPP is mandatory
check_mpp_mandatory

echo "PASS"
exit 0