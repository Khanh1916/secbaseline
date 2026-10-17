#!/bin/bash

# DESCRIPTION:
# This script validates network device SSH security configuration
# following security requirements for secure remote access protocol SSH version 2
# with connection limits, user restrictions, and strong encryption protocols
#
# VALIDATION LOGIC:
# 1. Check if configuration file exists and is accessible
# 2. Validate SSH service is enabled and properly configured
# 3. Ensure SSH protocol version 2 is enforced
# 4. Check connection and rate limits are configured
# 5. Verify root login restrictions and strong cipher requirements
# 6. Validate password complexity and encryption policies
#
# STRICT VALIDATION REQUIREMENTS:
# - Secure remote access protocol SSH version 2 with connection limits, user restrictions, and strong encryption
# - All user accounts must have encrypted passwords
# - Root account must have strong password protection
# - Minimum password length of 10 characters required
# - Password requirements: uppercase, lowercase, numbers, special characters
# - Password storage using strong encryption algorithms sha256/sha512, sha1 for older devices
# - Protection against brute-force password guessing attacks
#
# SSH SECURITY REQUIREMENTS:
# 1. SSH service must be enabled under [edit system services ssh]
# 2. SSH restricted to version 2 (protocol-version v2)
# 3. SSH connection limit configured (connection-limit > 0)
# 4. SSH rate limit configured (rate-limit > 0)
# 5. Remote root-login denied (root-login deny)
# 6. Strong ciphers only (3DES or AES variants)
#
# PASSWORD SECURITY REQUIREMENTS:
# 1. All user accounts must have encrypted passwords
# 2. Root authentication must be configured with encrypted password
# 3. Password format must use strong hashing (sha512/sha256/sha1)
# 4. Password complexity policy enforced (minimum 10 characters)
# 5. Character set requirements (upper, lower, numeric, punctuation)
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
# ./8011.sh <config_file>
#
# EXIT CODES:
# 0 - PASS: All user accounts have encrypted passwords, root has strong password protection, minimum 10 character length, character requirements, strong encryption sha256/sha512/sha1, brute-force protection
# 1 - FAILED: Missing or inadequate SSH/password security configuration

# SSH Configuration Security Checker
# Check SSH configuration according to security standards

CONFIG_FILE="$1"

# Check if config file is provided
if [[ -z "$CONFIG_FILE" || ! -f "$CONFIG_FILE" ]]; then
    echo "FAILED"
    exit 1
fi

# Function to check SSH requirements
check_ssh_config() {
    # 1. Check if SSH service is enabled
    if ! grep -E "set system services ssh" "$CONFIG_FILE" >/dev/null 2>&1; then
        return 1
    fi
    
    # 2. Check SSH protocol version 2
    if ! grep -E "set system services ssh.*protocol-version v2" "$CONFIG_FILE" >/dev/null 2>&1; then
        return 1
    fi
    
    # 3. Check SSH connection limit is set (limit > 0)
    local connection_limit_line=$(grep -E "set system services ssh.*connection-limit [0-9]+" "$CONFIG_FILE")
    if [[ -z "$connection_limit_line" ]]; then
        return 1
    fi
    
    # Extract the limit value and check if > 0
    local limit=$(echo "$connection_limit_line" | sed -E 's/.*connection-limit ([0-9]+).*/\1/')
    if [[ "$limit" -le 0 ]]; then
        return 1
    fi
    
    # 4. Check SSH rate limit is configured
    if ! grep -E "set system services ssh.*rate-limit [0-9]+" "$CONFIG_FILE" >/dev/null 2>&1; then
        return 1
    fi
    
    # 5. Check root-login is denied
    if ! grep -E "set system services ssh.*root-login deny" "$CONFIG_FILE" >/dev/null 2>&1; then
        return 1
    fi
    
    # 6. Check SSH ciphers - only 3DES or AES allowed
    local cipher_lines=$(grep -E "set system services ssh.*ciphers" "$CONFIG_FILE")
    if [[ -n "$cipher_lines" ]]; then
        # Check each cipher line individually
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                # Extract cipher name from each line
                local cipher=$(echo "$line" | sed -E 's/.*set system services ssh ciphers ["'\'']*([^"'\'' ]+)["'\'']*.*$/\1/')
                
                # Check if cipher contains 3DES or AES (case insensitive)
                if [[ ! "$cipher" =~ (3DES|AES|aes|3des) ]]; then
                    return 1
                fi
            fi
        done <<< "$cipher_lines"
    else
        # If no ciphers are explicitly set, failed
        return 1
    fi
    
    return 0
}

# Function to check password security requirements
check_password_security() {
    # 1. Check password format (sha512/sha256/sha1)
    if ! grep -E "set system login password format (sha512|sha256|sha1)" "$CONFIG_FILE" >/dev/null 2>&1; then
        return 1
    fi
    
    # 2. Check minimum password length (10 characters)
    if ! grep -E "set system login password minimum-length (1[0-9]|[2-9][0-9])" "$CONFIG_FILE" >/dev/null 2>&1; then
        return 1
    fi
    
    # 3. Check character set requirements
    if ! grep -E "set system login password change-type character-sets" "$CONFIG_FILE" >/dev/null 2>&1; then
        return 1
    fi
    
    # 4. Check character requirements (upper, lower, numeric, punctuation)
    if ! grep -E "set system login password minimum-lower-cases [1-9]" "$CONFIG_FILE" >/dev/null 2>&1; then
        return 1
    fi
    
    if ! grep -E "set system login password minimum-upper-cases [1-9]" "$CONFIG_FILE" >/dev/null 2>&1; then
        return 1
    fi
    
    if ! grep -E "set system login password minimum-numerics [1-9]" "$CONFIG_FILE" >/dev/null 2>&1; then
        return 1
    fi
    
    if ! grep -E "set system login password minimum-punctuations [1-9]" "$CONFIG_FILE" >/dev/null 2>&1; then
        return 1
    fi
    
    # 5. Check all users have encrypted passwords
    local users=$(grep -E "set system login user" "$CONFIG_FILE" | awk '{print $5}' | sort -u)
    for user in $users; do
        if ! grep -E "set system login user $user authentication encrypted-password" "$CONFIG_FILE" >/dev/null 2>&1; then
            return 1
        fi
    done
    
    # 6. Check root authentication is configured
    if ! grep -E "set system root-authentication encrypted-password" "$CONFIG_FILE" >/dev/null 2>&1; then
        return 1
    fi
    
    return 0
}

# Main check logic
if check_ssh_config && check_password_security; then
    echo "PASS"
    exit 0
else
    echo "FAILED"
    exit 1
fi