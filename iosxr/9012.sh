#!/bin/bash
# Function to check AES password encryption

# DESCRIPTION:
# This script validates Cisco IOS XR configuration files to ensure proper
# password security configuration. All users must use strong encrypted passwords
# with proper password policies and AES encryption for stored passwords.
#
# VALIDATION CRITERIA:
# REQUIRED CONFIGURATIONS:
# - All username blocks must contain secret (not password type 7)
# - Each username block must have proper secret with encryption
# - Password policy must enforce: min-length >= 10, numeric >= 1, lower-case >= 1,
#   upper-case >= 1, special-char >= 1
# - All username blocks must use the valid password policy
# - Must have "password6 encryption aes" for AES password storage encryption
#
# FORBIDDEN CONFIGURATIONS:
# - No "password 7" (Vigenere cipher) in any user configuration
#
# USAGE:
# ./9012.sh <config_file>
#
# EXAMPLES:
# ./9012.sh router-config.txt
# ./9012.sh /path/to/cisco-config.cfg
#
# EXIT CODES:
# 0 - PASS: Configuration meets password security requirements
# 1 - FAIL: Configuration does not meet security requirements
# 2 - ERROR: File not found or invalid arguments
#
# REQUIREMENTS:
# - Bash 4.0 or higher
# - Read access to configuration files
# - grep, awk utilities (standard on most Unix/Linux systems)
#
# EXAMPLE SECURE CONFIGURATION:
# username cisco
#  group root-lr
#  policy AAA-PASSWORD-POL
#  secret 10 $6$d7nylmgTAv51l...$aRS7NeBE9hBtojfNMt80BDzf...
# !
# username admin
#  group root-lr
#  policy AAA-PASSWORD-POL
#  secret 10 $6$KDYB401NXVqM640.$y6v/wq4KuPt3IUaUktvgz8Fw...
# !
# aaa password-policy AAA-PASSWORD-POL
#  numeric 1
#  lower-case 1
#  min-length 10
#  upper-case 1
#  special-char 1
# !
# password6 encryption aes

# Global variable to store valid policy name
VALID_POLICY_NAME=""

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

# Function to check username blocks and their secret configurations
check_username_secret_blocks() {
    # Find all username lines (must start without space)
    local username_lines=$(grep "^username[[:space:]]\+[A-Za-z0-9_-]\+[[:space:]]*$" "$CONFIG_FILE")
    
    if [ -z "$username_lines" ]; then
        return 1
    fi
    
    # Check each username block has a secret
    while IFS= read -r username_line; do
        # Extract username from line
        local username=$(echo "$username_line" | awk '{print $2}')
        
        # Extract the block for this user (from username line to next ! or EOF)
        local user_block=$(sed -n "/^username[[:space:]]\+$username[[:space:]]*$/,/^![[:space:]]*$/p" "$CONFIG_FILE")
        
        # Check if this block contains a secret line
        if ! echo "$user_block" | grep -q "^[[:space:]]\+secret[[:space:]]\+"; then
            return 1
        fi
        
    done <<< "$username_lines"
    
    return 0
}

# Function to check for forbidden password type 7
check_no_password_type7() {
    # Check for any password 7 configurations (Vigenere cipher)
    if grep -q "^[[:space:]]\+password[[:space:]]\+7[[:space:]]\+" "$CONFIG_FILE"; then
        return 1
    fi
    
    return 0
}

# Function to check password policy requirements and get valid policy name
check_password_policy() {
    # Find all AAA password policy blocks
    local policy_blocks=$(grep "^aaa[[:space:]]\+password-policy[[:space:]]\+" "$CONFIG_FILE")
    
    if [ -z "$policy_blocks" ]; then
        return 1  # No AAA password policy found
    fi
    
    # Check each policy for required strong password configurations
    while IFS= read -r policy_line; do
        local policy_name=$(echo "$policy_line" | awk '{print $3}')
        
        # Extract this specific policy block content
        local policy_content=$(sed -n "/^aaa[[:space:]]\+password-policy[[:space:]]\+$policy_name[[:space:]]*$/,/^![[:space:]]*$/p" "$CONFIG_FILE")
        
        # Check all required strong password configurations
        local numeric_valid=false
        local lowercase_valid=false
        local minlength_valid=false
        local uppercase_valid=false
        local specialchar_valid=false
        
        # Check numeric requirement (>= 1)
        local numeric_value=$(echo "$policy_content" | grep "^[[:space:]]\+numeric[[:space:]]\+" | awk '{print $2}')
        if [ -n "$numeric_value" ] && expr "$numeric_value" \>= 1 >/dev/null 2>&1; then
            numeric_valid=true
        fi
        
        # Check lower-case requirement (>= 1)
        local lowercase_value=$(echo "$policy_content" | grep "^[[:space:]]\+lower-case[[:space:]]\+" | awk '{print $2}')
        if [ -n "$lowercase_value" ] && expr "$lowercase_value" \>= 1 >/dev/null 2>&1; then
            lowercase_valid=true
        fi
        
        # Check min-length requirement (>= 10)
        local minlength_value=$(echo "$policy_content" | grep "^[[:space:]]\+min-length[[:space:]]\+" | awk '{print $2}')
        if [ -n "$minlength_value" ] && expr "$minlength_value" \>= 10 >/dev/null 2>&1; then
            minlength_valid=true
        fi
        
        # Check upper-case requirement (>= 1)
        local uppercase_value=$(echo "$policy_content" | grep "^[[:space:]]\+upper-case[[:space:]]\+" | awk '{print $2}')
        if [ -n "$uppercase_value" ] && expr "$uppercase_value" \>= 1 >/dev/null 2>&1; then
            uppercase_valid=true
        fi
        
        # Check special-char requirement (>= 1)
        local specialchar_value=$(echo "$policy_content" | grep "^[[:space:]]\+special-char[[:space:]]\+" | awk '{print $2}')
        if [ -n "$specialchar_value" ] && expr "$specialchar_value" \>= 1 >/dev/null 2>&1; then
            specialchar_valid=true
        fi
        
        # If this policy has all required configurations, store it globally
        if [ "$numeric_valid" = true ] && [ "$lowercase_valid" = true ] && [ "$minlength_valid" = true ] && [ "$uppercase_valid" = true ] && [ "$specialchar_valid" = true ]; then
            VALID_POLICY_NAME="$policy_name"
            return 0
        fi
        
    done <<< "$policy_blocks"
    
    return 1  # No policy with all required strong password configurations found
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
check_aes_encryption() {
    # Check for password6 encryption aes
    if grep -q "^password6[[:space:]]\+encryption[[:space:]]\+aes[[:space:]]*$" "$CONFIG_FILE"; then
        return 0
    fi
    
    return 1
}

# Main validation logic
# Step 1: Check username blocks and their secrets
check_username_secret_blocks
if [ $? -ne 0 ]; then
    echo "FAIL"
    # Uncomment below line for detailed debugging:
    # echo "FAIL: Some username blocks missing secret or no users found"
    exit 1
fi

# Step 2: Check for forbidden password type 7
check_no_password_type7
if [ $? -ne 0 ]; then
    echo "FAIL"
    # Uncomment below line for detailed debugging:
    # echo "FAIL: Found forbidden password type 7 (Vigenere cipher)"
    exit 1
fi

# Step 3: Check password policy requirements and get valid policy
check_password_policy
if [ $? -ne 0 ]; then
    echo "FAIL"
    # Uncomment below line for detailed debugging:
    # echo "FAIL: Password policy does not meet strong password requirements"
    exit 1
fi

# Step 4: Check username policy configuration
check_username_policy
if [ $? -ne 0 ]; then
    echo "FAIL"
    # Uncomment below line for detailed debugging:
    # echo "FAIL: Some users not using the valid password policy"
    exit 1
fi

# Step 5: Check AES encryption
check_aes_encryption
if [ $? -ne 0 ]; then
    echo "FAIL"
    # Uncomment below line for detailed debugging:
    # echo "FAIL: AES password encryption not configured"
    exit 1
fi

# All checks passed
echo "PASS"
exit 0