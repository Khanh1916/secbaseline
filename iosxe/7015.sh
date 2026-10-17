#!/bin/bash

# Cisco IOS-XE Configuration Archive Backup Validation Script
# Commercial Software Compatible - Version 1.0
# 
# Purpose: Validate archive configuration backup settings for disaster recovery
# Ensures automated configuration backup and change management capabilities
# Input: Configuration file path as argument
# Output: PASS or FAIL
# 
# Usage: ./7015.sh <config_file>
# Example: ./7015.sh running-config.txt
#
# Requirements:
# - Configuration file must be readable
# - Script expects standard Cisco IOS-XE configuration format
# - Supports running-config and startup-config files
#
# Archive Configuration Validation Rules:
# 
# 1. Archive Block Structure:
#    - Must have "archive" configuration block
#    - Contains all backup-related configuration parameters
#    - Essential for automated configuration management
#
# 2. Required Archive Components:
#    a) Path Configuration: "path <backup_location>"
#       - Specifies where configuration backups are stored
#       - Supports local flash, network locations (TFTP/FTP/SCP)
#
#    b) Write-Memory Trigger: "write-memory"
#       - Automatically creates backup when configuration saved
#       - Ensures backup synchronization with configuration changes
#
#    c) Time-Period Setting: "time-period <minutes>"
#       - Defines automatic backup interval
#       - Provides scheduled backup capability
#
# Disaster Recovery Benefits:
# - Automated configuration backup and versioning
# - Quick recovery from configuration corruption
# - Change tracking and configuration history
# - Rollback capability for failed changes
# - Compliance with backup and recovery policies
# - Reduced manual backup administration overhead
#
# Backup Strategy Components:
# - Automatic triggers (write-memory, time-based)
# - Centralized storage (network locations)
# - Version control (numbered backup files)
# - Change detection and incremental backups
# - Integration with configuration management systems
#
# Common Failure Scenarios:
# - Missing archive configuration block
# - Incomplete archive configuration (missing path/write-memory/time-period)
# - Unreachable backup storage location
# - Insufficient storage space for backups
# - Network connectivity issues to backup server
#
# Compliance Standards:
# - Configuration backup and recovery best practices
# - Disaster recovery planning requirements
# - Change management and version control policies
# - Enterprise backup and archival standards
# - Network infrastructure protection guidelines
#
# Return Codes:
# 0 = PASS (complete archive configuration with all required components)
# 1 = FAIL (missing archive block or incomplete configuration)
# 2 = Invalid input or file access error
#
# Technical Notes:
# - Uses AWK for archive block parsing and validation
# - Validates all three required archive components
# - Handles multi-line configuration block structure
# - Supports flexible whitespace and indentation

config_file="$1"

# Check input parameter and file existence
if [ ! -f "$config_file" ]; then
  echo "Usage: $0 <config-file>"
  exit 1
fi

# Parse archive block and validate required components
awk '
BEGIN { in_archive=0; has_path=0; has_wm=0; has_tp=0; }
/^archive\s*$/ { in_archive=1; next }
/^[^ ]/ { in_archive=0 }  # Exit block when encountering non-indented line
{
  if (in_archive) {
    if ($0 ~ /^\s*path\s+/) has_path=1;
    if ($0 ~ /^\s*write-memory\s*$/) has_wm=1;
    if ($0 ~ /^\s*time-period\s+/) has_tp=1;
  }
}
END {
  if (has_path && has_wm && has_tp) {
    print "PASS";
  } else {
    print "FAIL";
    exit 1;
  }
}
' "$config_file"