#!/bin/bash

# Cisco IOS-XE Configuration SSH Security Validation Script
# Commercial Software Compatible - Version 1.0
# 
# Purpose: Validate SSH version 2 configuration and VTY transport input restrictions
# Ensures secure remote access by enforcing modern SSH protocol and blocking insecure protocols
# Input: Configuration file path as argument
# Output: PASS or FAILED
# 
# Usage: ./7011.sh <config_file>
# Example: ./7011.sh running-config.txt
#
# Requirements:
# - Configuration file must be readable
# - Script expects standard Cisco IOS-XE configuration format
# - Supports running-config and startup-config files
#
# SSH Security Validation Rules:
# 
# 1. SSH Protocol Version:
#    - Must have: "ip ssh version 2"
#    - SSH version 2 provides stronger encryption and security
#    - Prevents use of vulnerable SSH version 1 protocol
#    - Essential for secure remote management
#
# 2. VTY Transport Input Restriction:
#    - All "line vty" blocks must have: "transport input ssh"
#    - Blocks insecure protocols (telnet, rlogin, etc.)
#    - Enforces SSH-only access for all virtual terminal lines
#    - Prevents plaintext credential transmission
#
# Security Benefits:
# - Eliminates weak SSH v1 cryptographic vulnerabilities
# - Prevents credential theft through protocol downgrade attacks
# - Blocks unencrypted telnet and rlogin access
# - Ensures all remote management uses strong encryption
# - Protects against man-in-the-middle attacks on management traffic
# - Compliance with modern security standards
#
# Protocol Security Comparison:
# - SSH v2: Strong encryption, key exchange, integrity protection
# - SSH v1: Weak encryption, known vulnerabilities (deprecated)
# - Telnet: No encryption, plaintext credentials (insecure)
# - Rlogin: No encryption, trust-based authentication (insecure)
#
# Common Failure Scenarios:
# - SSH version not specified (defaults to v1 on older IOS)
# - VTY lines allowing telnet access alongside SSH
# - Missing "transport input ssh" on some VTY lines
# - Mixed transport protocols creating security gaps
#
# Compliance Standards:
# - SSH protocol security best practices
# - Enterprise remote access security policies
# - Network device hardening guidelines
# - Secure management channel requirements
#
# Return Codes:
# 0 = PASS (SSH v2 configured and all VTY lines SSH-only)
# 1 = FAILED (missing SSH v2 or insecure VTY transport configuration)
# 2 = Invalid input or file access error
#
# Technical Notes:
# - Uses case-insensitive matching for SSH version command
# - AWK parsing handles multi-line VTY block validation
# - Supports flexible whitespace in configuration format
# - Validates all VTY line blocks consistently

config_file="$1"
has_error=0

# Check input parameter and file existence
if [ ! -f "$config_file" ]; then
  echo "FAILED"
  exit 1
fi

# 1. Check for SSH version 2 configuration (allows leading whitespace)
if ! grep -iq '^\s*ip ssh version 2' "$config_file"; then
  has_error=1
fi

# 2. Check that all line vty blocks have "transport input ssh" (allows whitespace)
awk '
  BEGIN { block=""; in_vty=0; failed=0 }

  /^\s*line vty/ {
    if (in_vty && block !~ /\n\s*transport input ssh(\s|$)/) failed=1;
    block=$0; in_vty=1; next;
  }

  /^\S/ {
    if (in_vty && block !~ /\n\s*transport input ssh(\s|$)/) failed=1;
    block=""; in_vty=0;
  }

  {
    if (in_vty) block = block "\n" $0;
  }

  END {
    if (in_vty && block !~ /\n\s*transport input ssh(\s|$)/) failed=1;
    exit failed;
  }
' "$config_file" || has_error=1

# Final result evaluation
if [ "$has_error" -eq 0 ]; then
  echo "PASS"
else
  echo "FAILED"
fi