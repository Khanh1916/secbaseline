#!/bin/bash
# DESCRIPTION:
# This script validates Cisco IOS XR AAA authentication configuration
# following the comprehensive validation logic for centralized authentication
#
# VALIDATION LOGIC:
# 1. Find AAA groups or server hosts (RADIUS/TACACS+)
# 2. Check console and line default authentication (MUST have login authentication)
# 3. Check vty-pool line templates (ALL non-default templates MUST have login authentication)
# 4. Validate authentication configuration based on template analysis
#
# STRICT VALIDATION REQUIREMENTS:
# - All "line console" and "line default" blocks MUST contain "login authentication"
# - All non-default line templates used by vty-pools MUST contain "login authentication"
# - All authentication lists must reference valid AAA groups or built-in groups
# - Built-in groups (radius/tacacs+) require corresponding server definitions
#
# SAMPLE CONFIGURATION:
# # Example 1: PASS - All authentication values are "default"
# radius-server host 192.168.89.121 auth-port 1645 acct-port 1646
#  key 7 133743165A19377B
#  timeout 20
# !
# radius-server host 192.168.89.122 auth-port 1645 acct-port 1646
#  key 7 1425460F5D111979
#  timeout 20
# !
# tacacs-server host 192.168.89.111 port 49
#  key 7 021225585F053C724F1F
#  timeout 20
# !
# tacacs-server host 192.168.89.112 port 49
#  key 7 08356D4D5D1A36441159
#  timeout 20
# !
# aaa group server radius RADGRP
#  server 192.168.89.121 auth-port 1645 acct-port 1646
#  server 192.168.89.122 auth-port 1645 acct-port 1646
# !
# aaa group server tacacs+ TACGRP
#  server 192.168.89.111
#  server 192.168.89.112
#  vrf mgmt
#  holddown-time 120
# !
# aaa group server tacacs+ TACPLUS
#  vrf mgmt
#  server-private 192.168.89.104 port 49
#   key 7 01100B08095B545A61
#   timeout 10
#   holddown-time 60
# !
# aaa authentication login default group TACPLUS group TACGRP group RADGRP local
# line console login authentication default
# line default login authentication default
# !
# vty-pool default 0 4 line-template default
#
# # Example 2: FAILED - Template missing login authentication
# line template VTY-TEMP
#  password 7 08021D5D0A16544541
# !
# vty-pool UNSECURE-POOL 20 30 line-template VTY-TEMP
#
# # Example 3: PASS - Multiple VTY pools with proper authentication
# line template SSH-TEMP
#  login authentication VTY-AUTHEN
#  transport input ssh
# !
# aaa authentication login VTY-AUTHEN group TACPLUS local
# vty-pool SSH-POOL 10 15 line-template SSH-TEMP
# vty-pool MGMT-POOL 5 9 line-template default
#
# USAGE:
# ./aaa_auth_check_v2.sh <config_file>
#
# EXIT CODES:
# 0 - PASS: Configuration meets requirements
# 1 - FAILED: Configuration does not meet requirements
# 2 - ERROR: File not found or invalid arguments

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

# Step 1: Find AAA groups and server hosts
step1_check_servers_groups() {
    local has_servers=false
    local has_groups=false
    
    # Check for radius-server or tacacs-server host
    if grep -qi "radius-server[[:space:]]\+host\|tacacs-server[[:space:]]\+host" "$CONFIG_FILE"; then
        has_servers=true
    fi
    
    # Check for aaa group server (handle tacacs+ with proper escaping)
    if grep -qi "aaa[[:space:]]\+group[[:space:]]\+server[[:space:]]\+\(radius\|tacacs[+]\)" "$CONFIG_FILE"; then
        has_groups=true
    fi
    
    # Must have at least one
    if [ "$has_servers" = false ] && [ "$has_groups" = false ]; then
        return 1  # FAILED - no servers or groups found
    fi
    
    return 0  # Found servers or groups
}

# Extract AAA group names
get_aaa_groups() {
    # Extract group names from both radius and tacacs+ groups
    # Note: tacacs+ needs proper escaping for the + character
    local groups=$(grep -i "aaa[[:space:]]\+group[[:space:]]\+server[[:space:]]\+\(radius\|tacacs[+]\)" "$CONFIG_FILE" | \
                   sed -n 's/^[[:space:]]*aaa[[:space:]]\+group[[:space:]]\+server[[:space:]]\+\(radius\|tacacs[+]\)[[:space:]]\+\([A-Za-z0-9_-]\+\).*/\2/ip' | \
                   sort -u | tr '\n' ' ' | sed 's/[[:space:]]*$//')
    
    echo "$groups"
}

# Check server types for built-in group validation
check_server_types() {
    local has_radius=false
    local has_tacacs=false
    
    if grep -qi "radius-server[[:space:]]\+host\|aaa[[:space:]]\+group[[:space:]]\+server[[:space:]]\+radius" "$CONFIG_FILE"; then
        has_radius=true
    fi
    
    if grep -qi "tacacs-server[[:space:]]\+host\|aaa[[:space:]]\+group[[:space:]]\+server[[:space:]]\+tacacs[+]" "$CONFIG_FILE"; then
        has_tacacs=true
    fi
    
    echo "$has_radius $has_tacacs"
}

# Step 2: Check console and line default authentication (STRICT: must have login authentication)
step2_get_line_auth() {
    local console_auth=""
    local line_default_auth=""
    
    # Extract console authentication - MUST exist in 'line console' block
    console_auth=$(sed -n '/^line console[[:space:]]*$/,/^![[:space:]]*$/p' "$CONFIG_FILE" | \
                  grep -i "login[[:space:]]\+authentication" | \
                  sed -n 's/^[[:space:]]*login[[:space:]]\+authentication[[:space:]]\+\([A-Za-z0-9_-]\+\).*/\1/ip' | head -1)
    
    # Extract line default authentication - MUST exist in 'line default' block
    line_default_auth=$(sed -n '/^line default[[:space:]]*$/,/^![[:space:]]*$/p' "$CONFIG_FILE" | \
                       grep -i "login[[:space:]]\+authentication" | \
                       sed -n 's/^[[:space:]]*login[[:space:]]\+authentication[[:space:]]\+\([A-Za-z0-9_-]\+\).*/\1/ip' | head -1)
    
    # STRICT CHECK: Both console and line default MUST have login authentication
    if [ -z "$console_auth" ] || [ -z "$line_default_auth" ]; then
        return 1
    fi
    
    echo "$console_auth $line_default_auth"
}

# Step 3: Get vty-pool and line-template pairs (STRICT: validate all templates)
step3_get_vty_pairs() {
    # Extract vty-pool name and line-template pairs with immediate validation
    grep -i "vty-pool" "$CONFIG_FILE" | while IFS= read -r vty_line; do
        # Extract pool name (first word after vty-pool)
        pool_name=$(echo "$vty_line" | sed -n 's/^[[:space:]]*vty-pool[[:space:]]\+\([A-Za-z0-9_-]\+\).*/\1/ip')
        
        # Extract template name
        template_name=$(echo "$vty_line" | sed -n 's/.*line-template[[:space:]]\+\([A-Za-z0-9_-]\+\).*/\1/ip')
        
        # Output as pool:template pair
        if [ -n "$pool_name" ] && [ -n "$template_name" ]; then
            echo "$pool_name:$template_name"
        fi
    done
}

# Validate all templates used by vty-pools (separate function to avoid subshell issues)
validate_vty_templates() {
    local vty_pairs="$1"
    
    # Check each vty-pool template
    echo "$vty_pairs" | while IFS=: read -r pool_name template_name; do
        # STRICT CHECK: If template is not "default", it MUST have login authentication
        if [ "$template_name" != "default" ]; then
            local template_auth=$(sed -n "/^line template $template_name[[:space:]]*$/,/^![[:space:]]*$/p" "$CONFIG_FILE" | \
                                 grep -i "login[[:space:]]\+authentication" | \
                                 sed -n 's/^[[:space:]]*login[[:space:]]\+authentication[[:space:]]\+\([A-Za-z0-9_-]\+\).*/\1/ip' | head -1)
            
            if [ -z "$template_auth" ]; then
                return 1  # Template missing login authentication
            fi
        fi
    done
}

# Get authentication value from line template (STRICT: must have login authentication)
get_template_auth() {
    local template_name="$1"
    local template_auth=""
    
    # Extract authentication from template block
    template_auth=$(sed -n "/^line template $template_name[[:space:]]*$/,/^![[:space:]]*$/p" "$CONFIG_FILE" | \
                   grep -i "login[[:space:]]\+authentication" | \
                   sed -n 's/^[[:space:]]*login[[:space:]]\+authentication[[:space:]]\+\([A-Za-z0-9_-]\+\).*/\1/ip' | head -1)
    
    # STRICT: Non-default templates MUST have login authentication
    if [ "$template_name" != "default" ] && [ -z "$template_auth" ]; then
        return 1
    fi
    
    # Return the authentication value
    echo "$template_auth"
}

# Check if authentication list has valid groups
validate_auth_list() {
    local auth_list="$1"
    local aaa_groups="$2"
    local has_radius="$3"
    local has_tacacs="$4"
    
    # Find the authentication list definition
    local auth_line=$(grep -i "aaa[[:space:]]\+authentication[[:space:]]\+login[[:space:]]\+$auth_list" "$CONFIG_FILE")
    
    if [ -z "$auth_line" ]; then
        return 1  # Auth list not found
    fi
    
    # Extract group names from the auth line
    local groups=$(echo "$auth_line" | grep -o "group[[:space:]]\+[A-Za-z0-9_+-]\+" | \
                  sed 's/group[[:space:]]\+//' | sort -u)
    
    if [ -z "$groups" ]; then
        return 1  # No groups found
    fi
    
    # Check each group for validity
    for group in $groups; do
        # Check user-defined AAA groups
        if [ -n "$aaa_groups" ]; then
            case " $aaa_groups " in
                *" $group "*)
                    return 0  # Found valid AAA group
                    ;;
            esac
        fi
        
        # Check built-in groups with corresponding server requirements
        if [ "$group" = "radius" ] && [ "$has_radius" = "true" ]; then
            return 0  # Valid built-in radius group
        fi
        
        if [ "$group" = "tacacs+" ] && [ "$has_tacacs" = "true" ]; then
            return 0  # Valid built-in tacacs+ group
        fi
    done
    
    return 1  # No valid groups found
}

# Step 4: Template authentication validation
step4_validate_template_auth() {
    local vty_pairs="$1"
    local console_auth="$2" 
    local line_default_auth="$3"
    local aaa_groups="$4"
    local has_radius="$5"
    local has_tacacs="$6"
    
    # Determine validation case based on authentication values
    local all_default=true
    
    # Check if console and line default use "default" authentication
    if [ "$console_auth" != "default" ] || [ "$line_default_auth" != "default" ]; then
        all_default=false
    fi
    
    # Check if any vty-pool uses non-default template
    if echo "$vty_pairs" | grep -v ":default$" >/dev/null; then
        all_default=false
    fi
    
    if [ "$all_default" = "true" ]; then
        # Case 4.1: All authentication values are "default"
        # Only need to validate the "default" authentication list
        if ! validate_auth_list "default" "$aaa_groups" "$has_radius" "$has_tacacs"; then
            return 1
        fi
    else
        # Case 4.2: Some values are not "default"
        # Need to validate each specific authentication list
        
        # 4.2.1: Validate each non-default template
        local vty_pairs_temp=$(echo "$vty_pairs")
        while IFS=: read -r pool_name template_name; do
            if [ "$template_name" != "default" ]; then
                # Get authentication value from template block
                local template_auth=$(get_template_auth "$template_name")
                
                # Template validation already done in step3 and get_template_auth
                # Now validate the authentication list referenced by the template
                if ! validate_auth_list "$template_auth" "$aaa_groups" "$has_radius" "$has_tacacs"; then
                    return 1
                fi
            fi
        done <<< "$vty_pairs_temp"
        
        # 4.2.2: Check non-default console/line default authentication
        if [ "$console_auth" != "default" ]; then
            if ! validate_auth_list "$console_auth" "$aaa_groups" "$has_radius" "$has_tacacs"; then
                return 1
            fi
        fi
        
        if [ "$line_default_auth" != "default" ]; then
            if ! validate_auth_list "$line_default_auth" "$aaa_groups" "$has_radius" "$has_tacacs"; then
                return 1
            fi
        fi
        
        # 4.2.3: Check if "default" authentication is still referenced
        local uses_default=false
        
        # Check if console or line default uses "default"
        if [ "$console_auth" = "default" ] || [ "$line_default_auth" = "default" ]; then
            uses_default=true
        fi
        
        # Check if any template is "default" or uses "default" authentication
        local vty_pairs_temp=$(echo "$vty_pairs")
        while IFS=: read -r pool_name template_name; do
            if [ "$template_name" = "default" ]; then
                uses_default=true
                break
            fi
            
            # Check if template uses "default" authentication
            local template_auth=$(get_template_auth "$template_name")
            if [ "$template_auth" = "default" ]; then
                uses_default=true
                break
            fi
        done <<< "$vty_pairs_temp"
        
        # If "default" is still referenced, validate it
        if [ "$uses_default" = "true" ]; then
            if ! validate_auth_list "default" "$aaa_groups" "$has_radius" "$has_tacacs"; then
                return 1
            fi
        fi
    fi
    
    return 0
}

# Main validation logic

# Step 1: Check AAA servers/groups exist
if ! step1_check_servers_groups; then
    echo "FAILED"
    exit 1
fi

# Get AAA groups and server types
AAA_GROUPS="$(get_aaa_groups)"
SERVER_TYPES=$(check_server_types)
HAS_RADIUS=$(echo "$SERVER_TYPES" | cut -d' ' -f1)
HAS_TACACS=$(echo "$SERVER_TYPES" | cut -d' ' -f2)

# Step 2: Get line authentication values (strict validation)
LINE_AUTH=$(step2_get_line_auth)
if [ $? -ne 0 ]; then
    echo "FAILED"
    exit 1
fi

CONSOLE_AUTH=$(echo "$LINE_AUTH" | cut -d' ' -f1)  # console auth
LINE_DEFAULT_AUTH=$(echo "$LINE_AUTH" | cut -d' ' -f2)  # line default auth

# Step 3: Get VTY pool-template pairs (strict validation)
VTY_PAIRS=$(step3_get_vty_pairs)
if [ -z "$VTY_PAIRS" ]; then
    echo "FAILED"
    exit 1
fi

# Validate all templates used by vty-pools
if ! validate_vty_templates "$VTY_PAIRS"; then
    echo "FAILED"
    exit 1
fi

# Step 4: Template Authentication Validation
if ! step4_validate_template_auth "$VTY_PAIRS" "$CONSOLE_AUTH" "$LINE_DEFAULT_AUTH" "$AAA_GROUPS" "$HAS_RADIUS" "$HAS_TACACS"; then
    echo "FAILED"
    exit 1
fi

echo "PASS"
exit 0