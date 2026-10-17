#!/bin/bash

# DESCRIPTION:
# This script validates Cisco NX-OS configuration files to ensure proper
# VTY access control is configured with access-list restrictions.
#
# VALIDATION CRITERIA:
# - Line vty must have "access-class <ACL-NAME> in"
# - Corresponding access-list <ACL-NAME> must exist
# - Access-list must NOT contain "permit tcp|ip any ..." rules
# - Returns PASS only if all criteria are met
#
# USAGE:
# ./10004.sh <config_file>
#
# EXAMPLES:
# ./10004.sh router-config.txt
# ./10004.sh /path/to/cisco-config.cfg
#
# SAMPLE CONFIGURATION:
# object-group ip address TRUSTED_MGMT_IP
#   10 host 192.168.255.20 
#   20 host 192.168.1.100
#   30 192.168.2.0/24 
# ip access-list ACL-VTY-IN
#   10 remark ALLOW ACCESS FROM TRUSTED_MGMT_IP
#   20 permit tcp addrgroup TRUSTED_MGMT_IP any eq 22 
#   100 deny ip any any 
# line vty
#   access-class ACL-VTY-IN in
#
# EXIT CODES:
# 0 - PASS: VTY access control properly configured
# 1 - FAILED: Missing or incorrect VTY access control
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

# Function to extract VTY block and find access-class
get_vty_access_class() {
    awk '
    BEGIN { in_section = 0; found_section = 0; found_access_class = 0 }
    
    # Match line vty - starts at beginning of line
    /^line[[:space:]]+vty/ {
        in_section = 1
        found_section = 1
        next
    }
    
    # End section when we hit command at beginning of line OR empty line
    in_section && (/^[^[:space:]]/ || /^[[:space:]]*$/) {
        in_section = 0
    }
    
    # Find access-class in current section
    in_section && /^[[:space:]]+access-class[[:space:]]+[^[:space:]]+[[:space:]]+in/ {
        match($0, /access-class[[:space:]]+([^[:space:]]+)[[:space:]]+in/, arr)
        if (arr[1]) {
            print arr[1]
            found_access_class = 1
            exit 0
        }
    }
    
    END {
        if (found_access_class == 1) {
            # Already printed access-class name, do nothing
        } else if (found_section == 0) {
            print "VTY_SECTION_NOT_FOUND"
        } else {
            print "ACCESS_CLASS_NOT_FOUND"
        }
    }
    ' "$CONFIG_FILE"
}

# Function to check if access-list exists
check_access_list_exists() {
    local acl_name="$1"
    
    if grep -q "^ip[[:space:]]\+access-list[[:space:]]\+${acl_name}[[:space:]]*$" "$CONFIG_FILE"; then
        echo "ACL_EXISTS"
    else
        echo "ACL_NOT_EXISTS"
    fi
}

# Function to check access-list rules for "permit any"
check_access_list_rules() {
    local acl_name="$1"
    
    awk -v acl_name="$acl_name" '
    BEGIN { in_section = 0; found_section = 0; found_permit_any = 0; checked = 0 }
    
    # Match ip access-list <ACL-NAME> - starts at beginning of line
    $0 ~ "^ip[[:space:]]+access-list[[:space:]]+" acl_name "[[:space:]]*$" {
        in_section = 1
        found_section = 1
        next
    }
    
    # End section when we hit command at beginning of line OR empty line
    in_section && (/^[^[:space:]]/ || /^[[:space:]]*$/) {
        in_section = 0
    }
    
    # Check for permit tcp|ip any rules in current section
    in_section && /^[[:space:]]+[0-9]+[[:space:]]+permit[[:space:]]+(tcp|ip)[[:space:]]+any/ {
        found_permit_any = 1
        checked = 1
        print "PERMIT_ANY_FOUND"
        exit 0
    }
    
    END {
        if (checked == 1) {
            # Already printed result, do nothing
        } else if (found_section == 0) {
            print "ACL_SECTION_NOT_FOUND"
        } else {
            print "NO_PERMIT_ANY"
        }
    }
    ' "$CONFIG_FILE"
}

# Get access-class from line vty
vty_access_class=$(get_vty_access_class)

# Check if we found access-class
if [ "$vty_access_class" = "VTY_SECTION_NOT_FOUND" ]; then
    echo "FAILED"
    exit 1
elif [ "$vty_access_class" = "ACCESS_CLASS_NOT_FOUND" ]; then
    echo "FAILED"
    exit 1
fi

# Check if corresponding access-list exists
acl_exists=$(check_access_list_exists "$vty_access_class")
if [ "$acl_exists" != "ACL_EXISTS" ]; then
    echo "FAILED"
    exit 1
fi

# Check access-list rules for permit any
acl_rules_check=$(check_access_list_rules "$vty_access_class")
if [ "$acl_rules_check" = "PERMIT_ANY_FOUND" ]; then
    echo "FAILED"
    exit 1
elif [ "$acl_rules_check" = "ACL_SECTION_NOT_FOUND" ]; then
    echo "FAILED"
    exit 1
fi

# All checks passed
echo "PASS"
exit 0