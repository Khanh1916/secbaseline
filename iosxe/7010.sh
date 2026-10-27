#!/bin/bash

# Cisco IOS-XE Configuration SNMP Security Validation Script
# Commercial Software Compatible - Version 1.0
# 
# Purpose: Validate SNMP community string and access control configuration
# Ensures secure SNMP monitoring with proper access restrictions and host authentication
# Input: Configuration file path as argument
# Output: PASS or FAIL
# 
# Usage: ./7010.sh <config_file>
# Example: ./7010.sh running-config.txt
#
# Requirements:
# - Configuration file must be readable
# - Script expects standard Cisco IOS-XE configuration format
# - Supports running-config and startup-config files
#
# SNMP Security Validation Rules:
# 
# 1. Community String with ACL:
#    - EVERY "snmp-server community" line must be "<string> RO <acl>"
#      (named or numbered ACL); an RW community or one without ACL fails
#    - SNMPv3 groups must use "priv" (authentication and encryption)
#    - No community and no group: SNMP is not running, which passes
#    - RO (Read-Only) access prevents unauthorized configuration changes
#    - ACL restricts which hosts can access SNMP services
#
# 2. Access Control List Definition:
#    - Referenced ACL must be defined: "ip access-list <type> <acl_name>" or
#      "access-list <number> ..."
#    - Prevents configuration errors with undefined ACLs
#    - Ensures access restrictions are properly implemented
#
# 3. SNMP Host Configuration:
#    - Must have: "snmp-server host <address> <community_string>"
#    - When communities exist, a host must use one of them
#    - Ensures consistent authentication across SNMP configuration
#
# Security Benefits:
# - Prevents unauthorized SNMP access from unknown hosts
# - Restricts SNMP operations to read-only for monitoring
# - Enforces consistent community string usage
# - Protects against SNMP-based reconnaissance attacks
# - Supports secure network monitoring and management
#
# Common Failure Scenarios:
# - Missing community string configuration
# - Community configured without ACL restriction
# - Referenced ACL not defined in configuration
# - SNMP host using different community string
# - Missing snmp-server host configuration
#
# Compliance Standards:
# - SNMP security best practices
# - Network monitoring access control policies
# - Enterprise SNMP management guidelines
# - Information security monitoring requirements
#
# Return Codes:
# 0 = PASS (SNMP properly secured with ACL and consistent community strings)
# 1 = FAIL (missing configuration or security violations)
# 2 = Invalid input or file access error
#
# Technical Notes:
# - Extracts ACL name and community string from snmp-server community command
# - Validates ACL definition exists in configuration
# - Verifies community string consistency between community and host commands
# - Uses pattern matching for flexible configuration format support

config_file="$1"

# Check input parameter and file existence
if [ ! -f "$config_file" ]; then
  echo "FAIL"
  exit 1
fi

if awk '
  { sub(/[ \t\r]+$/, "") }
  /^ip access-list (standard|extended) / { defined[$4] = 1 }
  /^access-list [0-9]+ / { defined[$2] = 1 }

  # snmp-server community <string> [view <v>] RO|RW [<acl>]
  /^snmp-server community / {
    communities++
    access = ""; acl = ""
    for (i = 4; i <= NF; i++) {
      if ($i == "view") { i++; continue }
      if ($i == "RO" || $i == "RW") { access = $i; acl = $(i + 1); break }
    }
    if (access != "RO" || acl == "") bad = 1
    else used[acl] = 1
    name[$3] = 1
  }

  /^snmp-server group [^ ]+ v3 / { if ($5 != "priv") bad = 1 }
  /^snmp-server group [^ ]+ v(1|2c) / { bad = 1 }

  /^snmp-server host / {
    for (i = 3; i <= NF; i++) host_word[$i] = 1
  }

  END {
    if (bad) exit 1
    for (a in used) if (!(a in defined)) exit 1
    if (communities) {
      for (c in name) if (c in host_word) exit 0
      exit 1
    }
    exit 0
  }
' "$config_file"; then
  echo "PASS"
  exit 0
fi

echo "FAIL"
exit 1
