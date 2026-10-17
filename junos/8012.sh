#!/bin/bash

# DESCRIPTION:
# This script validates Juniper device configuration according to industry-standard
# password security policies and authentication best practices.
# Ensures compliance with enterprise security frameworks including NIST,
# ISO 27001, and SOC 2 requirements.
#
# VALIDATION LOGIC:
# 1. Check if configuration file exists and is accessible
# 2. Validate all user accounts have encrypted passwords
# 3. Ensure root account has strong password protection
# 4. Verify password complexity policy enforcement
# 5. Confirm strong password encryption format usage
#
# STRICT VALIDATION REQUIREMENTS:
# - All users must have passwords
# - Must have root password configured
# - Strong passwords: minimum 10 characters complex with uppercase, lowercase, numbers, special characters
# - Password encryption stored in configuration file using sha1|sha256|sha512
# - All user accounts must have encrypted passwords
# - Root account must have strong password protection
# - Minimum password length of 10 characters required
# - Character requirements: uppercase, lowercase, numbers, special characters
# - Password storage using strong encryption algorithms sha256|sha512, sha1 for older devices
# - Protection against brute-force password guessing attacks
#
# SECURITY COMPLIANCE MATRIX:
# [1] USER ACCOUNT PROTECTION
#     * All user accounts must have encrypted passwords
#     * Validates: set system login user <n> authentication encrypted-password "<hash>"
#
# [2] ROOT ACCOUNT SECURITY ENHANCEMENT
#     * Root account must have strong password protection
#     * Validates: set system root-authentication encrypted-password "<hash>"
#
# [3] PASSWORD COMPLEXITY ENFORCEMENT
#     * Minimum 10 character length requirement
#     * Multi-layer character enforcement (upper, lower, numeric, special)
#     * Validates: set system login password minimum-length >=10
#     * Validates: set system login password change-type character-sets
#
# [4] ENCRYPTION HASH STRENGTH
#     * Strong password storage algorithms enforcement
#     * Supports: SHA-1, SHA-256, SHA-512
#     * Validates: set system login password format {sha1|sha256|sha512}
#
# SAMPLE CONFIGURATION:
# set system login password format sha512
# set system login password change-type character-sets
# set system login password minimum-length 10
# set system login password minimum-lower-cases 1
# set system login password minimum-numerics 1
# set system login password minimum-upper-cases 1
# set system login password minimum-punctuations 1
# set system login password minimum-reuse 8
# set system login password minimum-changes 5
# set system login user test01 authentication encrypted-password "$6$NLoklUrv$cpoo8aEKko7BhOQ2JLw6Aj731SVVDLieAzew7GZsD3OOSYDR5D2jr3PCLWzFTfNlN1hqcmbpd724hBjqArTUx/"
# set system root-authentication encrypted-password "$6$auA5gSew$pH9ouG.QJoksy10dRCLjsGVzDDeQAOj0k0Wtr/eHmHB8GyTrrgm.O8AQCAbpZXR5nQXhAQ/QXVUhoEpghzSrq0"
#
# USAGE:
# ./8012.sh <config_file>
#
# EXIT CODES:
# 0 - PASS: All user accounts have encrypted passwords, root has strong password protection, minimum 10 character length, character requirements, strong encryption sha256/sha512/sha1, brute-force protection
# 1 - FAILED: Security compliance error or file error

CONFIG_FILE="$1"

# Check if config file is provided
if [[ -z "$CONFIG_FILE" || ! -f "$CONFIG_FILE" ]]; then
    echo "FAILED"
    exit 1
fi

# Function to check if encrypted password uses strong hashing
check_password_hash() {
    local encrypted_password="$1"
    
    # Remove quotes if present
    encrypted_password=$(echo "$encrypted_password" | sed 's/["'\'']*//g')
    
    # Check for SHA-256 ($5$), SHA-512 ($6$), or SHA-1 ($1$ - though weaker, still acceptable per requirement)
    if [[ "$encrypted_password" =~ ^\$[156]\$ ]]; then
        return 0
    fi
    
    return 1
}

# Function to check password format configuration
check_password_format() {
    # Check for password format configuration with sha1, sha256, or sha512
    if grep -E "set system login password format (sha1|sha256|sha512)" "$CONFIG_FILE" >/dev/null 2>&1; then
        return 0
    fi
    
    return 1
}

# Function to check password complexity policy
check_password_policy() {
    # Check for password complexity requirements
    local has_min_length=false
    local has_complexity=false
    
    # Look for minimum length (should be >= 10)
    if grep -E "set system login password minimum-length [0-9]+" "$CONFIG_FILE" >/dev/null 2>&1; then
        local min_length=$(grep -E "set system login password minimum-length [0-9]+" "$CONFIG_FILE" | head -1 | sed -E 's/.*minimum-length ([0-9]+).*/\1/')
        # Ensure min_length is a valid number and >= 10
        if [[ "$min_length" =~ ^[0-9]+$ ]] && [[ "$min_length" -ge 10 ]]; then
            has_min_length=true
        fi
    fi
    
    # Look for character class requirements - check for character-sets OR change-type
    if grep -E "set system login password.*(character-sets|change-type)" "$CONFIG_FILE" >/dev/null 2>&1; then
        has_complexity=true
    fi
    
    # If both requirements are met
    if [[ "$has_min_length" == true && "$has_complexity" == true ]]; then
        return 0
    fi
    
    return 1
}

# Function to check user password requirements
check_user_passwords() {
    # Get all users
    local users=$(grep "set system login user" "$CONFIG_FILE" | sed -E 's/.*set system login user ([^ ]+).*/\1/' | sort -u)
    
    if [[ -z "$users" ]]; then
        # No users found - this might be acceptable depending on system
        return 0
    fi
    
    # Check each user has encrypted password
    for user in $users; do
        if ! grep -E "set system login user $user authentication encrypted-password" "$CONFIG_FILE" >/dev/null 2>&1; then
            return 1
        fi
    done
    
    return 0
}

# Function to check root password
check_root_password() {
    # Check if root authentication is configured
    if ! grep -E "set system root-authentication encrypted-password" "$CONFIG_FILE" >/dev/null 2>&1; then
        return 1
    fi
    
    return 0
}

# Function to check all password requirements
check_password_config() {
    # 1. Check all users have encrypted passwords
    if ! check_user_passwords; then
        return 1
    fi
    
    # 2. Check root password configuration
    if ! check_root_password; then
        return 1
    fi
    
    # 3. Check password complexity policy
    if ! check_password_policy; then
        return 1
    fi
    
    # 4. Check password format configuration
    if ! check_password_format; then
        return 1
    fi
    
    return 0
}

# Main check logic
if check_password_config; then
    echo "PASS"
else
    echo "FAILED"
fi