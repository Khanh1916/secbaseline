#!/bin/bash

# DESCRIPTION:
# This script validates Cisco NX-OS configuration files to ensure proper
# SNMP security configuration with restricted access and authentication.
#
# VALIDATION CRITERIA:
# - Must NOT have insecure SNMP communities (public/private/rw/network-admin)
# - Must have "snmp-server globalEnforcePriv"
# - Must have "snmp-server enable traps"
# - Must have "snmp-server host ..." for IP restrictions
# - Version 2c communities must have ACL restrictions
# - Version 3 users in host configs must have auth-sha and priv-aes
# - Returns PASS only if all criteria are met
#
# USAGE:
# ./10010.sh <config_file>
#
# EXAMPLES:
# ./10010.sh router-config.txt
# ./10010.sh /path/to/cisco-config.cfg
#
# SAMPLE CONFIGURATION:
# snmp-server globalEnforcePriv
# snmp-server enable traps
# snmp-server host 192.168.89.104 use-vrf management
# snmp-server community secure_community group snmp-view
# snmp-server community secure_community use-ipv4acl ACL-SNMP-RO
# snmp-server user secure_user network-operator auth sha ... priv aes-128 ...
# snmp-server host 192.168.89.104 version 3 priv secure_user
#
# EXIT CODES:
# 0 - PASS: SNMP security properly configured
# 1 - FAIL: Insecure or missing SNMP configuration
# 2 - ERROR: File not found or invalid arguments
#
# REQUIREMENTS:
# - Bash 4.0 or higher
# - Read access to configuration files
# - grep, awk utilities (standard on most Unix/Linux systems)

# Check arguments
if [ $# -ne 1 ]; then
    echo "FAIL"
    exit 1
fi

CONFIG_FILE="$1"

# Check file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "FAIL"
    exit 1
fi

# Function to check for forbidden SNMP configurations
check_forbidden_snmp() {
    # Check for insecure community strings only (not user roles)
    if grep -qi "^snmp-server[[:space:]]\+community[[:space:]]\+\(public\|private\)" "$CONFIG_FILE" || \
       grep -qi "^snmp-server[[:space:]]\+community.*[[:space:]]\+rw[[:space:]]*$" "$CONFIG_FILE" || \
       grep -qi "^snmp-server[[:space:]]\+community.*group[[:space:]]\+network-admin" "$CONFIG_FILE"; then
        echo "FORBIDDEN_FOUND"
    else
        echo "NO_FORBIDDEN"
    fi
}

# Function to check required SNMP configurations
check_required_snmp() {
    local config_type="$1"
    
    case "$config_type" in
        "globalEnforcePriv")
            if grep -qi "^snmp-server[[:space:]]\+globalEnforcePriv" "$CONFIG_FILE"; then
                echo "CONFIGURED"
            else
                echo "NOT_CONFIGURED"
            fi
            ;;
        "enable_traps")
            if grep -qi "^snmp-server[[:space:]]\+enable[[:space:]]\+traps" "$CONFIG_FILE"; then
                echo "CONFIGURED"
            else
                echo "NOT_CONFIGURED"
            fi
            ;;
        "host_restriction")
            if grep -qi "^snmp-server[[:space:]]\+host[[:space:]]\+" "$CONFIG_FILE"; then
                echo "CONFIGURED"
            else
                echo "NOT_CONFIGURED"
            fi
            ;;
    esac
}

# Function to check if version 2c communities have ACL
check_v2c_communities() {
    # Get communities from "snmp-server host ... version 2c <community>"
    local v2c_communities=$(grep -i "^snmp-server[[:space:]]\+host.*version[[:space:]]\+2c[[:space:]]\+" "$CONFIG_FILE" | awk '{
        # Find "version 2c" pattern and get the community after it
        for (i=1; i<=NF-2; i++) {
            if (tolower($i) == "version" && tolower($(i+1)) == "2c") {
                print $(i+2)
                break
            }
        }
    }')

    # ...and every community defined for polling ("snmp-server community <name> ..."),
    # which answers queries whether or not a trap host uses it
    v2c_communities=$(printf '%s\n%s\n' "$v2c_communities" \
        "$(grep -i "^snmp-server[[:space:]]\+community[[:space:]]\+" "$CONFIG_FILE" | awk '{print $3}')" | sed '/^$/d' | sort -u)

    if [ -z "$v2c_communities" ]; then
        echo "NO_V2C"
        return
    fi
    
    # Check each community has ACL and ACL exists
    for community in $v2c_communities; do
        # Escape special characters in community name for grep
        local escaped_community=$(printf '%s\n' "$community" | sed 's/[[\.*^$()+?{|]/\\&/g')
        
        # Find ACL name for this community
        local acl_name=$(grep -i "^snmp-server[[:space:]]\+community[[:space:]]\+${escaped_community}[[:space:]]\+use-ipv4acl[[:space:]]\+" "$CONFIG_FILE" | awk '{
            for (i=1; i<=NF; i++) {
                if (tolower($i) == "use-ipv4acl" && i < NF) {
                    print $(i+1)
                    break
                }
            }
        }')
        
        if [ -z "$acl_name" ]; then
            echo "COMMUNITY_NO_ACL"
            return
        fi
        
        # Check if ACL exists
        if ! grep -qi "^ip[[:space:]]\+access-list[[:space:]]\+${acl_name}[[:space:]]*$" "$CONFIG_FILE"; then
            echo "ACL_NOT_EXISTS"
            return
        fi
    done
    
    echo "ALL_COMMUNITIES_HAVE_VALID_ACL"
}

# Function to check version 3 users in host configurations
check_v3_host_users() {
    # Get users from "snmp-server host ... version 3 priv <user>"
    local v3_users=$(grep -i "^snmp-server[[:space:]]\+host.*version[[:space:]]\+3[[:space:]]\+priv[[:space:]]\+" "$CONFIG_FILE" | awk '{
        for (i=1; i<=NF; i++) {
            if (tolower($i) == "priv" && i < NF) {
                print $(i+1)
                break
            }
        }
    }')
    
    if [ -z "$v3_users" ]; then
        echo "NO_V3_HOSTS"
        return
    fi
    
    # Check each user has auth sha and priv aes
    for user in $v3_users; do
        if ! grep -qi "^snmp-server[[:space:]]\+user[[:space:]]\+${user}.*auth[[:space:]]\+sha.*priv[[:space:]]\+aes" "$CONFIG_FILE"; then
            echo "USER_MISSING_AUTH_PRIV"
            return
        fi
    done
    
    echo "ALL_V3_USERS_SECURE"
}

# Initialize validation status
failed=false
failure_reasons=()

# Check for forbidden configurations
forbidden_status=$(check_forbidden_snmp)
if [ "$forbidden_status" = "FORBIDDEN_FOUND" ]; then
    failed=true
    failure_reasons+=("Found forbidden SNMP configuration (public/private/rw/network-admin)")
fi

# Check required configurations
global_enforce_status=$(check_required_snmp "globalEnforcePriv")
if [ "$global_enforce_status" != "CONFIGURED" ]; then
    failed=true
    failure_reasons+=("Missing 'snmp-server globalEnforcePriv'")
fi

enable_traps_status=$(check_required_snmp "enable_traps")
if [ "$enable_traps_status" != "CONFIGURED" ]; then
    failed=true
    failure_reasons+=("Missing 'snmp-server enable traps'")
fi

host_restriction_status=$(check_required_snmp "host_restriction")
if [ "$host_restriction_status" != "CONFIGURED" ]; then
    failed=true
    failure_reasons+=("Missing 'snmp-server host' IP restriction")
fi

# Check version 2c security
v2c_status=$(check_v2c_communities)
case "$v2c_status" in
    "COMMUNITY_NO_ACL")
        failed=true
        failure_reasons+=("Version 2c community without ACL restriction")
        ;;
    "ACL_NOT_EXISTS")
        failed=true
        failure_reasons+=("Version 2c community ACL does not exist")
        ;;
    "NO_V2C")
        # No v2c communities - this is OK
        ;;
    "ALL_COMMUNITIES_HAVE_VALID_ACL")
        # All v2c communities have valid ACL - this is good
        ;;
esac

# Check version 3 security
v3_status=$(check_v3_host_users)
case "$v3_status" in
    "USER_MISSING_AUTH_PRIV")
        failed=true
        failure_reasons+=("Version 3 user in host config missing auth-sha or priv-aes")
        ;;
    "NO_V3_HOSTS")
        # No v3 host configurations - this is OK
        ;;
    "ALL_V3_USERS_SECURE")
        # All v3 users have proper auth/priv - this is good
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