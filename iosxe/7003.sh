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
#    - exec-timeout 5 0 : Session timeout of 5 minutes, 0 seconds
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
# - Each block must contain "exec-timeout 5 0" command
# - Missing timeout in any block results in FAIL
# - If no line blocks configured -> PASS (not applicable)
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
  echo "Usage: $0 <config-file>"
  exit 1
fi

config_file="$1"

awk '
  BEGIN {
    block = ""; in_block = 0; block_header = "";
  }

  /^line (con|vty)/ {
    if (in_block && block !~ /exec-timeout 5 0/) {
      exit 1;
    }
    in_block = 1;
    block_header = $0;
    block = $0;
    next;
  }

  /^[^ ]/ {
    if (in_block && block ~ /^line (con|vty)/ && block !~ /exec-timeout 5 0/) {
      exit 1;
    }
    in_block = 0;
    block = "";
    block_header = "";
  }

  {
    if (in_block) block = block "\n" $0;
  }

  END {
    if (in_block && block ~ /^line (con|vty)/ && block !~ /exec-timeout 5 0/) {
      exit 1;
    }
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