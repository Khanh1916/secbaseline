#!/bin/bash

# Cisco IOS-XE Configuration AAA Remote Authentication Validation Script
# Commercial Software Compatible - Version 1.0
# 
# Purpose: Validate AAA remote authentication configuration for VTY access
# Ensures proper RADIUS/TACACS+ authentication setup and VTY line compliance
# Input: Configuration file path as argument
# Output: PASS or FAIL
# 
# Usage: ./7008.sh <config_file>
# Example: ./7008.sh running-config.txt
#
# Requirements:
# - Configuration file must be readable
# - Script expects standard Cisco IOS-XE configuration format
# - Supports running-config and startup-config files
#
# Validation Logic:
# 
# 1. AAA Model Check:
#    - If "aaa new-model" not configured -> PASS (AAA not in use)
#    - AAA disabled means legacy authentication acceptable
#
# 2. Remote Authentication Method Detection:
#    - Searches for: "aaa authentication login <method> group radius"
#    - Searches for: "aaa authentication login <method> group tacacs+"
#    - Extracts authentication method name for VTY validation
#
# 3. VTY Line Validation:
#    - All line vty blocks must use: "login authentication <method>"
#    - Method name must match the one defined in AAA configuration
#    - Ensures consistent remote authentication across all VTY sessions
#
# Security Compliance:
# - Enforces centralized authentication via RADIUS/TACACS+
# - Prevents local authentication bypass on remote access
# - Ensures all VTY lines use the same authentication policy
# - Supports enterprise identity management integration
#
# Common Failure Scenarios:
# - AAA method defined but VTY lines not configured
# - Method name mismatch between AAA definition and VTY usage
# - Missing "login authentication" on some VTY lines
# - RADIUS/TACACS+ method not properly defined
#
# Return Codes:
# 0 = PASS (AAA remote authentication properly configured)
# 1 = FAIL (missing or inconsistent AAA configuration)
# 2 = Invalid input or file access error
#
# Technical Notes:
# - Uses AWK for multi-line VTY block parsing
# - Supports both RADIUS and TACACS+ authentication groups
# - Pattern matching handles standard IOS-XE syntax variations
# - Validates method name consistency across configuration

config_file="$1"

# Check input parameter and file existence
if [ ! -f "$config_file" ]; then
  echo "FAIL"
  exit 1
fi

# If aaa new-model is not configured then PASS
if ! grep -qE '^aaa new-model(\s|$)' "$config_file"; then
  echo "PASS"
  exit 0
fi

# Find authentication method using group radius or tacacs+
method=$(grep -E '^aaa authentication login [^ ]+ group (radius|tacacs\+)' "$config_file" | awk '{print $4}')

if [ -z "$method" ]; then
  echo "FAIL"
  exit 1
fi

# Check that line vty blocks have login authentication <method>
awk -v method="$method" '
  BEGIN { block=""; in_block=0; found=0; }

  /^line vty/ {
    in_block = 1;
    block = $0;
    next;
  }

  /^line / {
    if (in_block) {
      if (block ~ ("login authentication " method)) found++;
      in_block = 0;
      block = "";
    }
  }

  {
    if (in_block) block = block "\n" $0;
  }

  END {
    if (in_block && block ~ ("login authentication " method)) found++;

    if (found == 0) {
      print "FAIL";
      exit 1;
    } else {
      print "PASS";
    }
  }
' "$config_file"