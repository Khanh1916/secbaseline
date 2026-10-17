#!/bin/bash

# DESCRIPTION:
# This script validates Juniper device archival configuration to ensure
# automatic configuration backup with configured archive sites
# and trigger mechanism (commit or interval) is established.
#
# VALIDATION LOGIC:
# 1. Check if configuration file exists and is accessible
# 2. Validate at least one archive site is configured
# 3. Verify transfer trigger mechanism is configured
# 4. Ensure automatic backup functionality is properly set up
#
# STRICT VALIDATION REQUIREMENTS:
# - Periodic configuration backup or when "commit" command is executed
# - At least one archive site must be configured
# - One of two trigger mechanisms must be configured:
#   * Transfer on commit - backup after each commit
#   * Transfer interval - backup at time intervals
# - BOTH REQUIREMENTS MUST BE MET TO ENSURE AUTOMATIC BACKUP
#
# JUNOS BACKUP REQUIREMENTS:
# [1] ARCHIVE SITES CONFIGURATION
#     * Must have at least one archive site configured
#     * Validates: set system archival configuration archive-sites <url>
#     * Examples: ftp://user:pass@server/path/ or scp://user@server:/path/
#
# [2] TRANSFER TRIGGER MECHANISM
#     * Must have one of two trigger mechanisms configured:
#       a) Transfer on commit - backup after each commit
#       b) Transfer interval - backup at time intervals
#     * Validates: set system archival configuration transfer-on-commit
#       OR: set system archival configuration transfer-interval <minutes>
#
# SAMPLE CONFIGURATION:
# set system archival configuration transfer-interval 2880
# set system archival configuration transfer-on-commit
# set system archival configuration archive-sites ftp://10.255.100.100
# set system archival configuration archive-sites file:///var/tmp/config-backup/
#
# USAGE:
# ./8015.sh <config_file>
#
# EXIT CODES:
# 0 - PASS: At least one archive site configured, one of two trigger mechanisms configured (transfer on commit or transfer interval)
# 1 - FAILED: Missing backup configuration or trigger mechanism

CONFIG_FILE="$1"

# Function to display usage
# show_usage() {
#     echo "Usage: $0 <config_file>"
#     echo ""
#     echo "Parameters:"
#     echo "  config_file  - Junos configuration file (required)"
#     echo ""
#     echo "Examples:"
#     echo "  $0 config.txt"
#     echo "  $0 /path/to/junos.conf"
#     echo ""
#     echo "Required configurations:"
#     echo "  1. Archive sites:"
#     echo "     set system archival configuration archive-sites <url>"
#     echo ""
#     echo "  2. Transfer trigger (one of the following):"
#     echo "     set system archival configuration transfer-on-commit"
#     echo "     OR"
#     echo "     set system archival configuration transfer-interval <minutes>"
#     echo ""
#     echo "Example valid configuration:"
#     echo "  set system archival configuration archive-sites \"ftp://backup:pass@10.1.1.100/configs/\""
#     echo "  set system archival configuration transfer-on-commit"
# }

# Validate input parameters
if [[ -z "$CONFIG_FILE" ]]; then
    echo "FAILED"
    # show_usage >&2
    exit 1
fi

# Check if config file exists and is readable
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "FAILED"
    exit 1
fi

if [[ ! -r "$CONFIG_FILE" ]]; then
    echo "FAILED"
    exit 1
fi

# Function to check archive sites configuration
check_archive_sites() {
    # Check if at least one archive site is configured
    if grep -E "set system archival configuration archive-sites" "$CONFIG_FILE" >/dev/null 2>&1; then
        return 0
    fi
    
    return 1
}

# Function to check transfer-on-commit configuration
check_transfer_on_commit() {
    # Check if transfer-on-commit is configured
    if grep -E "set system archival configuration transfer-on-commit" "$CONFIG_FILE" >/dev/null 2>&1; then
        return 0
    fi
    
    return 1
}

# Function to check transfer-interval configuration
check_transfer_interval() {
    # Check if transfer-interval is configured with a value
    if grep -E "set system archival configuration transfer-interval" "$CONFIG_FILE" >/dev/null 2>&1; then
        return 0
    fi
    
    return 1
}

# Function to check transfer trigger mechanism
check_transfer_trigger() {
    # Check if either transfer-on-commit OR transfer-interval is configured
    if check_transfer_on_commit || check_transfer_interval; then
        return 0
    fi
    
    return 1
}

# Main validation logic
check_backup_config() {
    # 1. Check archive sites configuration
    if ! check_archive_sites; then
        return 1
    fi
    
    # 2. Check transfer trigger mechanism
    if ! check_transfer_trigger; then
        return 1
    fi
    
    return 0
}

# Execute main check
if check_backup_config; then
    echo "PASS"
else
    echo "FAILED"
fi