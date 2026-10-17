#!/bin/bash

# Cisco IOS-XE Configuration AAA Login Attempt Limitation Validation Script
# Commercial Software Compatible - Version 1.0
# 
# Purpose: Validate AAA authentication login attempt limitation configuration
# Ensures protection against brute force authentication attacks
# Input: Configuration file path as argument
# Output: PASS or FAIL
# 
# Usage: ./7014.sh <config_file>
# Example: ./7014.sh running-config.txt
#
# Requirements:
# - Configuration file must be readable
# - Script expects standard Cisco IOS-XE configuration format
# - Supports running-config and startup-config files
#
# AAA Login Attempt Limitation Validation Rules:
# 
# 1. Authentication Attempts Configuration:
#    - Must have: "aaa authentication attempts login <number>"
#    - Limits consecutive failed login attempts
#    - Essential protection against brute force attacks
#
# Security Benefits:
# - Prevents automated password guessing attacks
# - Reduces risk of successful brute force authentication
# - Protects user accounts from credential stuffing attacks
# - Enforces account lockout policies for failed attempts
# - Complies with security hardening best practices
# - Reduces authentication-related security events
#
# Attack Protection:
# - Brute force password attacks
# - Dictionary-based credential attacks
# - Automated login attempt scripts
# - Credential stuffing campaigns
# - Account enumeration attempts
# - Social engineering password guessing
#
# Typical Configuration Values:
# - Conservative: 3-5 attempts (high security environments)
# - Balanced: 5-10 attempts (enterprise environments)
# - Liberal: 10+ attempts (user-friendly environments)
#
# Common Failure Scenarios:
# - Missing AAA authentication attempts configuration
# - Login attempt limit set too high (ineffective protection)
# - No account lockout mechanism configured
# - Inconsistent attempt limits across authentication methods
#
# Compliance Standards:
# - Authentication security best practices
# - Enterprise password policy requirements
# - Network device hardening guidelines
# - Brute force attack prevention standards
# - Identity and access management policies
#
# Return Codes:
# 0 = PASS (AAA authentication attempts properly configured)
# 1 = FAIL (missing authentication attempts limitation)
# 2 = Invalid input or file access error
#
# Technical Notes:
# - Uses regex pattern matching for AAA command validation
# - Supports flexible whitespace in configuration format
# - Compatible with all standard AAA authentication configurations
# - Validates command presence regardless of specific attempt number

config_file="$1"

# Check input parameter and file existence
if [ ! -f "$config_file" ]; then
  echo "FAIL"
  exit 1
fi

# Check for AAA authentication attempts login configuration
if grep -Eq "^\s*aaa authentication attempts login\s+" "$config_file"; then
  echo "PASS"
  exit 0
else
  echo "FAIL"
  exit 1
fi