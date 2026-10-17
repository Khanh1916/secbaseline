#!/bin/bash

# DESCRIPTION:
# This script validates Cisco NX-OS configuration files to ensure proper
# strong password policy configuration is enabled.
#
# VALIDATION CRITERIA:
# - All usernames must have password configured (not "password 5 !")
# - Password strength check must be enabled (not "no password strength-check")
# - Minimum password length must be 10+ characters ("userpassphrase min-length 10")
# - Returns PASS only if all criteria are met
#
# USAGE:
# ./10012.sh <config_file>
#
# EXAMPLES:
# ./10012.sh router-config.txt
# ./10012.sh /path/to/cisco-config.cfg
#
# SAMPLE CONFIGURATION:
# username admin password 5 $5$BJPCFA$LYRf3TgFWHH3ACtusY6fehRV/zgVdsXfL3VlcgOSlW3 role network-admin
# password strength-check
# userpassphrase min-length 10
# userpassphrase default-warntime 5 
# userpassphrase default-gracetime 5
#
# EXIT CODES:
# 0 - PASS: Password policy is properly configured
# 1 - FAIL: Weak or missing password policy
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

# Function to check if all users have passwords configured
check_user_passwords() {
    # Find all username lines that contain "password"
    local username_password_lines=$(grep -i "^username[[:space:]]\+.*password[[:space:]]\+" "$CONFIG_FILE")
    
    if [ -z "$username_password_lines" ]; then
        echo "NO_USERS_WITH_PASSWORD_FOUND"
        return
    fi
    
    # Check each username line for password configuration
    while IFS= read -r line; do
        # Check if line contains "password 5 !" pattern (empty password)
        if echo "$line" | grep -qi "password[[:space:]]\+5[[:space:]]\+![[:space:]]\+role"; then
            echo "USER_WITHOUT_PASSWORD"
            return
        fi
        
        # Check if line contains password hash
        if ! echo "$line" | grep -qi "password[[:space:]]\+5[[:space:]]\+\$[^[:space:]]\+"; then
            echo "USER_WITHOUT_PASSWORD"
            return
        fi
    done <<< "$username_password_lines"
    
    echo "ALL_USERS_HAVE_PASSWORD"
}

# Function to check password strength-check status
check_password_strength() {
    # Check if password strength-check is disabled
    if grep -qi "^no[[:space:]]\+password[[:space:]]\+strength-check[[:space:]]*$" "$CONFIG_FILE"; then
        echo "STRENGTH_CHECK_DISABLED"
    else
        echo "STRENGTH_CHECK_ENABLED"
    fi
}

# Function to check minimum password length
check_min_password_length() {
    # Check for userpassphrase min-length 10 or higher
    local min_length_line=$(grep -i "^userpassphrase[[:space:]]\+min-length[[:space:]]\+" "$CONFIG_FILE")
    local min_length=$(echo "$min_length_line" | awk '{print $3}')
    
    if [ -z "$min_length" ]; then
        echo "MIN_LENGTH_NOT_SET"
        return
    fi
    
    # Check if min-length is 10 or higher
    if [ "$min_length" -ge 10 ] 2>/dev/null; then
        echo "MIN_LENGTH_VALID"
    else
        echo "MIN_LENGTH_TOO_LOW"
    fi
}

# Initialize validation status
failed=false
failure_reasons=()

# Check user passwords
user_password_status=$(check_user_passwords)
case "$user_password_status" in
    "USER_WITHOUT_PASSWORD")
        failed=true
        failure_reasons+=("Found username without password configuration")
        ;;
    "NO_USERS_WITH_PASSWORD_FOUND")
        failed=true
        failure_reasons+=("No usernames with password found in configuration")
        ;;
    "ALL_USERS_HAVE_PASSWORD")
        # All users have passwords - this is good
        ;;
esac

# Check password strength-check
strength_check_status=$(check_password_strength)
if [ "$strength_check_status" = "STRENGTH_CHECK_DISABLED" ]; then
    failed=true
    failure_reasons+=("Password strength-check is disabled")
fi

# Check minimum password length
min_length_status=$(check_min_password_length)
case "$min_length_status" in
    "MIN_LENGTH_NOT_SET")
        failed=true
        failure_reasons+=("Minimum password length not configured")
        ;;
    "MIN_LENGTH_TOO_LOW")
        failed=true
        failure_reasons+=("Minimum password length is less than 10 characters")
        ;;
    "MIN_LENGTH_VALID")
        # Min length is 10+ - this is good
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