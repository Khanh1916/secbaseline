#!/bin/bash
# Check file exists and is readable

# DESCRIPTION:
# This script validates Cisco IOS XR configuration files to ensure proper
# AAA authentication lockout configuration. The script checks if lockout-time
# and authen-max-attempts are configured in the AAA password policy, and
# verifies that all username accounts use the password policy.
#
# VALIDATION CRITERIA:
# REQUIRED CONFIGURATIONS:
# - Must have "lockout-time" configuration in aaa password-policy
# - Must have "authen-max-attempts" configuration in aaa password-policy
# - All username blocks must have "policy" configuration referencing the policy
#
# USAGE:
# ./9014.sh <config_file>
#
# EXAMPLES:
# ./9014.sh router-config.txt
# ./9014.sh /path/to/cisco-config.cfg
#
# EXIT CODES:
# 0 - PASS: Configuration has lockout settings and all users use password policy
# 1 - FAILED: Configuration missing lockout settings or users not using policy
# 2 - ERROR: File not found or invalid arguments
#
# REQUIREMENTS:
# - Bash 4.0 or higher
# - Read access to configuration files
# - grep, sed utilities (standard on most Unix/Linux systems)
#
# EXAMPLE VALID CONFIGURATION:
# aaa password-policy AAA-PASSWORD-POL
#  lockout-time minutes 30
#  authen-max-attempts 5
# !
# username cisco
#  policy AAA-PASSWORD-POL
# !
# username admin
#  policy AAA-PASSWORD-POL
# !

# Check arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 <config_file>"
    exit 1
fi

CONFIG_FILE="$1"

# Global variable to store valid policy name
VALID_POLICY_NAME=""
if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: File not found: $CONFIG_FILE"
    exit 1
fi

if [ ! -r "$CONFIG_FILE" ]; then
    echo "ERROR: Cannot read file: $CONFIG_FILE"
    exit 1
fi

# Function to check AAA lockout configuration and get valid policy name
check_aaa_lockout() {
    # Find all AAA password policy blocks
    local policy_blocks=$(grep "^aaa[[:space:]]\+password-policy[[:space:]]\+" "$CONFIG_FILE")
    
    if [ -z "$policy_blocks" ]; then
        return 1  # No AAA password policy found
    fi
    
    # Check each policy for required lockout configurations
    while IFS= read -r policy_line; do
        local policy_name=$(echo "$policy_line" | awk '{print $3}')
        
        # Extract this specific policy block content
        local policy_content=$(sed -n "/^aaa[[:space:]]\+password-policy[[:space:]]\+$policy_name[[:space:]]*$/,/^![[:space:]]*$/p" "$CONFIG_FILE")
        
        # Check if this policy has both required configurations
        if echo "$policy_content" | grep -q "^[[:space:]]\+lockout-time[[:space:]]\+" && \
           echo "$policy_content" | grep -q "^[[:space:]]\+authen-max-attempts[[:space:]]\+"; then
            # Found a valid policy, store it globally
            VALID_POLICY_NAME="$policy_name"
            return 0
        fi
        
    done <<< "$policy_blocks"
    
    return 1  # No policy with both lockout configurations found
}

# Function to check username policy configuration
check_username_policy() {
    # Must have found valid policy in previous step
    if [ -z "$VALID_POLICY_NAME" ]; then
        return 1  # No valid policy found
    fi
    
    # Find all username lines
    local username_lines=$(grep "^username[[:space:]]\+[A-Za-z0-9_-]\+[[:space:]]*$" "$CONFIG_FILE")
    
    if [ -z "$username_lines" ]; then
        return 1  # No users found
    fi
    
    # Check each username block uses the VALID policy
    while IFS= read -r username_line; do
        # Extract username from line
        local username=$(echo "$username_line" | awk '{print $2}')
        
        # Extract the block for this user
        local user_block=$(sed -n "/^username[[:space:]]\+$username[[:space:]]*$/,/^![[:space:]]*$/p" "$CONFIG_FILE")
        
        # Check if this block uses the VALID policy (not just any policy)
        if ! echo "$user_block" | grep -q "^[[:space:]]\+policy[[:space:]]\+$VALID_POLICY_NAME[[:space:]]*$"; then
            return 1  # User not using the valid policy
        fi
        
    done <<< "$username_lines"
    
    return 0  # All users use the valid policy
}

# Main validation logic
# Step 1: Check AAA lockout configuration
check_aaa_lockout
if [ $? -ne 0 ]; then
    echo "FAILED"
    # Uncomment below line for detailed debugging:
    # echo "FAILED: Missing lockout-time or authen-max-attempts in AAA password policy"
    exit 1
fi

# Step 2: Check username policy configuration
check_username_policy
if [ $? -ne 0 ]; then
    echo "FAILED"
    # Uncomment below line for detailed debugging:
    # echo "FAILED: Some users missing password policy configuration"
    exit 1
fi

# All checks passed
echo "PASS"
exit 0