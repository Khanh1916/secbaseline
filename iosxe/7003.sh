#!/bin/bash

# Cisco IOS-XE Configuration Exec Timeout Validation Script
# Commercial Software Compatible - Version 1.0
# 
# Purpose: Validate exec-timeout configuration on console and VTY line interfaces
# Ensures session timeout compliance for security and resource management
# Input: Configuration file path as argument
# Output: PASS or FAIL
# 
# Usage: ./7003.sh <config_file>
# Example: ./7003.sh running-config.txt
#
# Requirements:
# - Configuration file must be readable
# - Script expects standard Cisco IOS-XE configuration format
# - Supports running-config and startup-config files
#
# Validation Rules:
# 
# 1. Target Interfaces:
#    - line con (console interface) : Physical console access
#    - line vty (virtual terminal)  : Telnet/SSH remote access
#
# 2. Required Configuration:
#    - exec-timeout <minutes> [<seconds>] of more than 0 and at most 5 minutes
#      ("exec-timeout 5 0", "exec-timeout 3 0", "exec-timeout 4 30")
#    - "exec-timeout 0 0" disables the timeout and fails
#    - Must be present in ALL configured line con/vty blocks
#
# 3. Security Rationale:
#    - Prevents idle sessions from remaining active indefinitely
#    - Reduces security exposure from unattended terminals
#    - Enforces consistent timeout policy across all access methods
#    - Helps prevent unauthorized access to abandoned sessions
#
# Validation Logic:
# - Scans all line con and line vty configuration blocks
# - Each block must contain an exec-timeout of at most 5 minutes
# - Missing timeout in any block results in FAIL
# - At least one line con and one line vty block must exist -> otherwise FAIL
#   (IOS XE always lists them; without them the timeout cannot be verified
#   and the default is 10 minutes)
#
# Compliance Standards:
# - Follows Cisco IOS-XE security hardening best practices
# - Meets enterprise session management requirements
# - Supports security audit and compliance reporting
#
# Return Codes:
# 0 = PASS (exec-timeout properly configured on all applicable interfaces)
# 1 = FAIL (missing or incorrect exec-timeout configuration)
# 2 = Invalid input or file access error
#
# Technical Notes:
# - Uses AWK for multi-line block parsing and validation
# - Handles configuration block boundaries correctly
# - Pattern matching supports standard IOS-XE syntax formatting

# Check input parameter and file existence
if [ -z "$1" ] || [ ! -f "$1" ]; then
  echo "FAIL"
  exit 1
fi

config_file="$1"

awk '
  # timeout: seconds of the block exec-timeout; 0 when missing or disabled.
  function close_block() {
    if (in_block && !(timeout > 0 && timeout <= 300)) bad = 1
    in_block = 0
  }

  { sub(/[ \t\r]+$/, "") }

  /^line (con|vty)/ {
    close_block()
    if ($2 ~ /^con/) seen_con = 1; else seen_vty = 1
    in_block = 1
    timeout = 0
    next
  }

  /^[^ ]/ { close_block() }

  in_block && /^ +exec-timeout [0-9]+( [0-9]+)?$/ { timeout = $2 * 60 + $3 }

  END {
    close_block()
    exit ((bad || !seen_con || !seen_vty) ? 1 : 0)
  }
' "$config_file"

# Final result evaluation
if [ $? -eq 0 ]; then
  echo "PASS"
  exit 0
else
  echo "FAIL"
  exit 1
fi