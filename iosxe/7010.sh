#!/bin/bash

# Cisco IOS-XE Configuration SNMP Security Validation Script
# Commercial Software Compatible - Version 1.0
# 
# Purpose: Validate SNMP community string and access control configuration
# Ensures secure SNMP monitoring with proper access restrictions and host authentication
# Input: Configuration file path as argument
# Output: PASS or FAILED
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
#    - Must have: "snmp-server community <string> RO <acl_name>"
#    - RO (Read-Only) access prevents unauthorized configuration changes
#    - ACL restricts which hosts can access SNMP services
#
# 2. Access Control List Definition:
#    - Referenced ACL must be defined: "ip access-list <type> <acl_name>"
#    - Prevents configuration errors with undefined ACLs
#    - Ensures access restrictions are properly implemented
#
# 3. SNMP Host Configuration:
#    - Must have: "snmp-server host <address> <community_string>"
#    - Community string must match the one defined in step 1
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
# 1 = FAILED (missing configuration or security violations)
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
  echo "FAILED"
  exit 1
fi

# Extract ACL_NAME and community string from: snmp-server community ... RO ACL_NAME
acl_name=$(grep -E '^snmp-server community [^ ]+ RO [^ ]+' "$config_file" | awk '{print $5}' | head -n1)
community=$(grep -E '^snmp-server community [^ ]+ RO [^ ]+' "$config_file" | awk '{print $3}' | head -n1)

# If either ACL name or community string is missing → FAILED
if [ -z "$acl_name" ] || [ -z "$community" ]; then
  echo "FAILED"
  exit 1
fi

# Check that the referenced access-list exists
if ! grep -qE "^ip access-list [^ ]+ $acl_name" "$config_file"; then
  echo "FAILED"
  exit 1
fi

# Check that snmp-server host uses the same community string
if ! grep -qE "snmp-server host .* $community(\s|$)" "$config_file"; then
  echo "FAILED"
  exit 1
fi

echo "PASS"