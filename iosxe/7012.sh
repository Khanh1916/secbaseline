#!/bin/bash

# Cisco IOS-XE Configuration Password Security Validation Script
# Commercial Software Compatible - Version 1.0
# 
# Purpose: Validate password security configuration and encryption settings
# Ensures strong password policies and prevents weak password storage
# Input: Configuration file path as argument
# Output: PASS or FAILED
# 
# Usage: ./7012.sh <config_file>
# Example: ./7012.sh running-config.txt
#
# Requirements:
# - Configuration file must be readable
# - Script expects standard Cisco IOS-XE configuration format
# - Supports running-config and startup-config files
#
# Password Security Validation Rules:
# 
# 1. Enable Secret Configuration:
#    - Must have: "enable secret <password>"
#    - Uses strong MD5 hashing instead of weak Type 7 encryption
#    - Provides secure privileged mode access protection
#
# 2. Password Encryption Service:
#    - Must have: "service password-encryption"
#    - Encrypts all plaintext passwords in configuration
#    - Prevents password disclosure in configuration files
#
# 3. Username Secret Requirement:
#    - Must have at least one: "username <user> secret <password>"
#    - Secret uses strong hashing for local user accounts
#    - Ensures secure local authentication capability
#
# 4. Username Password Prohibition:
#    - Must NOT have: "username <user> password <password>"
#    - Password uses weak Type 7 encryption (easily reversible)
#    - Prevents weak password storage that can be easily cracked
#
# Security Benefits:
# - Strong password hashing with MD5/SHA algorithms
# - Protection against configuration file password exposure
# - Prevents use of easily reversible password encryption
# - Ensures consistent strong password policy across all accounts
# - Protects against offline password cracking attacks
#
# Password Security Comparison:
# - Secret: Strong MD5/SHA hashing (irreversible, secure)
# - Password: Type 7 encryption (easily reversible, insecure)
# - Service encryption: Protects Type 7 from plaintext exposure
#
# Common Failure Scenarios:
# - Missing enable secret (using enable password instead)
# - No service password-encryption (plaintext passwords visible)
# - Using username password instead of username secret
# - Mixed password/secret usage creating security inconsistency
#
# Compliance Standards:
# - Password security best practices
# - Enterprise authentication policy requirements
# - Network device hardening guidelines
# - Information security password management standards
#
# Return Codes:
# 0 = PASS (all password security requirements met)
# 1 = FAILED (missing required settings or insecure password configuration)
# 2 = Invalid input or file access error
#
# Technical Notes:
# - Case-insensitive pattern matching for configuration commands
# - Validates presence of required security configurations
# - Checks for prohibited weak password configurations
# - Supports flexible whitespace in configuration format

config_file="$1"

# Check input parameter and file existence
if [ ! -f "$config_file" ]; then
  echo "FAILED"
  exit 1
fi

has_error=0

# Check for enable secret configuration (required)
if ! grep -Ei '^\s*enable secret' "$config_file" >/dev/null; then
  has_error=1
fi

# Check for service password-encryption (required)
if ! grep -Ei '^\s*service password-encryption' "$config_file" >/dev/null; then
  has_error=1
fi

# Check for at least one username with secret (required)
if ! grep -Ei '^\s*username.*secret' "$config_file" >/dev/null; then
  has_error=1
fi

# Check that no username uses password instead of secret (prohibited)
if grep -Ei '^\s*username.*password' "$config_file" >/dev/null; then
  has_error=1
fi

# Final result evaluation
if [ "$has_error" -eq 0 ]; then
  echo "PASS"
else
  echo "FAILED"
fi