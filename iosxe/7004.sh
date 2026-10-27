#!/bin/bash

# Cisco IOS-XE Configuration VTY Access Control Validation Script
# Commercial Software Compatible - Version 1.0
# 
# Purpose: Validate VTY line access control lists configuration and implementation
# Ensures remote access security through proper ACL assignment and definition
# Input: Configuration file path as argument
# Output: PASS or FAIL
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
#    - Format: "ip access-list [standard|extended] <acl_name>" or numbered
#      "access-list <number> ..."
#
# 3. Security Compliance:
#    - Follows principle of least privilege for remote access
#    - Prevents configuration errors with undefined ACLs
#    - Ensures consistent access control policy enforcement
#
# Validation Process:
# 1. Extract all ACL names from line vty access-class commands
# 2. Verify each referenced ACL is properly defined
# 3. FAIL if any VTY lacks access-class or ACL undefined
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
# 1 = FAIL (missing access-class or undefined ACL references)
# 2 = Invalid input or file access error
#
# Technical Notes:
# - Uses AWK for complex multi-line block parsing
# - Handles multiple VTY line blocks correctly
# - Supports both numbered and named ACL formats
# - Pattern matching with word boundaries for accuracy

# Check input parameter and file existence
if [ -z "$1" ] || [ ! -f "$1" ]; then
  echo "FAIL"
  exit 1
fi

# Plain POSIX awk: mawk, the default awk on Debian and Ubuntu, has no
# three-argument match()
if awk '
  # A vty block without access-class leaves remote access open.
  function close_block() {
    if (!in_vty) return
    if (acl == "") bad = 1
    else used[acl] = 1
    in_vty = 0
  }

  { sub(/[ \t\r]+$/, "") }
  /^ip access-list (standard|extended) / { defined[$4] = 1 }
  /^access-list [0-9]+ / { defined[$2] = 1 }

  /^line vty/ {
    close_block()
    in_vty = 1
    blocks++
    acl = ""
    next
  }
  /^[^ ]/ { close_block() }
  in_vty && /^ +access-class [^ ]+ in( vrf-also)?$/ { acl = $2 }

  END {
    close_block()
    if (!blocks || bad) exit 1
    for (a in used) if (!(a in defined)) exit 1
    exit 0
  }
' "$1"; then
  echo "PASS"
  exit 0
fi

echo "FAIL"
exit 1
