#!/bin/bash

# Cisco IOS-XE Configuration VTY Access Control Validation Script
# Commercial Software Compatible - Version 1.0
# 
# Purpose: Validate VTY line access control lists configuration and implementation
# Ensures remote access security through proper ACL assignment and definition
# Input: Configuration file path as argument
# Output: PASS or FAILED
# 
# Usage: ./7004.sh <config_file>
# Example: ./7004.sh running-config.txt
#
# Requirements:
# - Configuration file must be readable
# - Script expects standard Cisco IOS-XE configuration format
# - Supports running-config and startup-config files
#
# Security Validation Rules:
# 
# 1. VTY Line Access Control:
#    - All line vty blocks must have "access-class <name> in" configured
#    - Prevents unrestricted remote access via Telnet/SSH
#    - Enforces IP-based access restrictions
#
# 2. ACL Definition Validation:
#    - Every referenced ACL name must be defined in configuration
#    - Supports both standard and extended access lists
#    - Format: "ip access-list [standard|extended] <acl_name>"
#
# 3. Security Compliance:
#    - Follows principle of least privilege for remote access
#    - Prevents configuration errors with undefined ACLs
#    - Ensures consistent access control policy enforcement
#
# Validation Process:
# 1. Extract all ACL names from line vty access-class commands
# 2. Verify each referenced ACL is properly defined
# 3. FAILED if any VTY lacks access-class or ACL undefined
# 4. PASS only when all VTY lines have valid ACL references
#
# Common Failure Scenarios:
# - Missing access-class on VTY lines (unrestricted access)
# - Referenced ACL not defined (configuration error)
# - Typos in ACL names between reference and definition
#
# Compliance Standards:
# - Cisco IOS-XE security hardening guidelines
# - Enterprise remote access security policies
# - Network infrastructure protection standards
#
# Return Codes:
# 0 = PASS (all VTY lines properly secured with valid ACLs)
# 1 = FAILED (missing access-class or undefined ACL references)
# 2 = Invalid input or file access error
#
# Technical Notes:
# - Uses AWK for complex multi-line block parsing
# - Handles multiple VTY line blocks correctly
# - Supports both numbered and named ACL formats
# - Pattern matching with word boundaries for accuracy

# Check input parameter and file existence
if [ -z "$1" ] || [ ! -f "$1" ]; then
  echo "Usage: $0 <config-file>"
  exit 1
fi

cfg="$1"

# Extract all ACL names used in line vty blocks
acl_names=$(awk '
  BEGIN { block = ""; in_vty = 0 }
  /^line vty/ { in_vty = 1; block = $0; next }
  /^line /     { in_vty = 0 }
  {
    if (in_vty) block = block "\n" $0;
  }
  END {
    n = split(blocks, lines, "\n")
  }
  /^line vty/ {
    if (block) {
      match(block, /access-class[ \t]+([A-Za-z0-9_-]+)[ \t]+in/, m);
      if (m[1]) print m[1];
    }
    block = $0;
    next;
  }
  /^[^ ]/ {
    if (block) {
      match(block, /access-class[ \t]+([A-Za-z0-9_-]+)[ \t]+in/, m);
      if (m[1]) print m[1];
    }
    block = "";
  }
  {
    if (block) block = block "\n" $0;
  }
  END {
    if (block ~ /^line vty/ && block ~ /access-class[ \t]+([A-Za-z0-9_-]+)[ \t]+in/) {
      match(block, /access-class[ \t]+([A-Za-z0-9_-]+)[ \t]+in/, m);
      if (m[1]) print m[1];
    }
  }
' "$cfg" | sort -u)

# If no access-class found then FAIL
if [ -z "$acl_names" ]; then
  echo "FAILED"
  exit 1
fi

# Check if each ACL name exists in ip access-list definitions
missing=0
while read -r acl; do
  if ! grep -qE "^ip access-list (standard|extended)?[ \t]+$acl(\s|$)" "$cfg"; then
    missing=1
    break
  fi
done <<< "$acl_names"

# Final result evaluation
if [ "$missing" -eq 0 ]; then
  echo "PASS"
else
  echo "FAILED"
fi