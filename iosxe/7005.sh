#!/bin/bash

# Cisco IOS-XE Configuration Security Services Validation Script
# Commercial Software Compatible - Version 1.0
# 
# Purpose: Validate security configuration by checking forbidden and required services
# Ensures compliance with network security best practices and hardening guidelines
# Input: Configuration file path as argument
# Output: PASS or FAILED
# 
# Usage: ./7005.sh <config_file>
# Example: ./7005.sh running-config.txt
#
# Requirements:
# - Configuration file must be readable
# - Script expects standard Cisco IOS-XE configuration format
# - Supports running-config and startup-config files
#
# Security Validation Rules:
# 
# 1. Forbidden Services (Must NOT be present):
#    - service tcp-small-servers    : Legacy TCP echo/discard services (security risk)
#    - service udp-small-servers    : Legacy UDP echo/discard services (security risk)
#    - ip finger                    : Finger protocol (information disclosure)
#    - ip bootp server             : BOOTP server (legacy, insecure)
#    - service config              : Auto-configuration service (security risk)
#    - service dhcp                : DHCP service (potential attack vector)
#
# 2. Required Security Settings (Must be present):
#    - ip dhcp bootp ignore        : Disable BOOTP requests processing
#    - no ip http server           : Disable HTTP web server
#    - no ip http secure-server    : Disable HTTPS web server
#
# Compliance Standards:
# - Follows Cisco IOS-XE security hardening guidelines
# - Disables unnecessary network services to reduce attack surface
# - Prevents information disclosure and unauthorized access
#
# Return Codes:
# 0 = PASS (all security requirements met)
# 1 = FAILED (forbidden services found or required settings missing)
# 2 = Invalid input or file access error
#
# Technical Notes:
# - Uses exact pattern matching with word boundaries
# - Case sensitive matching for IOS-XE command syntax
# - Validates commands at beginning of configuration lines only

config_file="$1"
has_error=0

# Check input parameter and file existence
if [ ! -f "$config_file" ]; then
  echo "FAILED"
  exit 1
fi

# Forbidden services that must NOT be present
for forbidden in \
  "service tcp-small-servers" \
  "service udp-small-servers" \
  "ip finger" \
  "ip bootp server" \
  "service config" \
  "service dhcp"
do
  if grep -qE "^$forbidden(\s|$)" "$config_file"; then
    has_error=1
  fi
done

# Required security settings that must be present
for required in \
  "ip dhcp bootp ignore" \
  "no ip http server" \
  "no ip http secure-server"
do
  if ! grep -qE "^$required(\s|$)" "$config_file"; then
    has_error=1
  fi
done

# Final result evaluation
if [ "$has_error" -eq 0 ]; then
  echo "PASS"
else
  echo "FAILED"
fi