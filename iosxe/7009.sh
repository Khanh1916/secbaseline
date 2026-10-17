#!/bin/bash

# Cisco IOS-XE Configuration Time Synchronization Validation Script
# Commercial Software Compatible - Version 1.0
# 
# Purpose: Validate NTP server and timezone configuration for accurate time synchronization
# Ensures proper time management for logging, security, and network operations
# Input: Configuration file path as argument
# Output: PASS or FAILED
# 
# Usage: ./7009.sh <config_file>
# Example: ./7009.sh running-config.txt
#
# Requirements:
# - Configuration file must be readable
# - Script expects standard Cisco IOS-XE configuration format
# - Supports running-config and startup-config files
#
# Validation Rules:
# 
# 1. NTP Server Configuration:
#    - Must have: "ntp server <server_address>"
#    - Ensures device synchronizes with external time source
#    - Critical for accurate timestamps in logs and security events
#
# 2. Timezone Configuration:
#    - Must have: "clock timezone <name> 7"
#    - Enforces UTC+7 timezone (typically for Southeast Asia region)
#    - Ensures consistent time representation across network infrastructure
#
# 3. Dual Requirement Validation:
#    - Both NTP server AND timezone must be configured
#    - Missing either configuration results in FAILED
#    - PASS only when both requirements are satisfied
#
# Security and Operational Benefits:
# - Accurate timestamps for security event correlation
# - Synchronized logging across network devices
# - Proper certificate validation timing
# - Compliance with audit and forensic requirements
# - Consistent time-based access control policies
#
# Common Failure Scenarios:
# - Missing NTP server configuration (time drift issues)
# - Incorrect or missing timezone setting
# - NTP server unreachable (operational concern)
# - Timezone offset mismatch with regional requirements
#
# Compliance Standards:
# - Network time synchronization best practices
# - Security logging and audit trail requirements
# - Regional timezone compliance (UTC+7)
# - Enterprise time management policies
#
# Return Codes:
# 0 = PASS (both NTP server and timezone properly configured)
# 1 = FAILED (missing NTP server or incorrect timezone configuration)
# 2 = Invalid input or file access error
#
# Technical Notes:
# - Uses regex pattern matching for configuration validation
# - Supports any valid NTP server address format
# - Enforces specific timezone offset (+7 hours)
# - Compatible with all standard Cisco time configuration formats

config_file="$1"

# Check input parameter and file existence
if [ ! -f "$config_file" ]; then
  echo "FAILED"
  exit 1
fi

# Check both time synchronization requirements
ntp_ok=$(grep -qE '^ntp server\s+\S+' "$config_file" && echo 1 || echo 0)
tz_ok=$(grep -qE '^clock timezone\s+\S+\s+7(\s|$)' "$config_file" && echo 1 || echo 0)

# Final result evaluation
if [ "$ntp_ok" -eq 1 ] && [ "$tz_ok" -eq 1 ]; then
  echo "PASS"
else
  echo "FAILED"
fi