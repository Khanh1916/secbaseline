#!/bin/bash

# DESCRIPTION:
# This script validates Cisco IOS XR configuration files to ensure proper
# automatic configuration backup settings. The script checks if auto-save
# configuration is enabled for either local disk or remote server.
#
# VALIDATION CRITERIA:
# REQUIRED CONFIGURATIONS:
# - Must have "configuration commit auto-save filename ..." configuration
# - Supports both local disk and remote server (SFTP) backup
#
# USAGE:
# ./9015.sh <config_file>
#
# EXAMPLES:
# ./9015.sh router-config.txt
# ./9015.sh /path/to/cisco-config.cfg
#
# EXIT CODES:
# 0 - PASS: Configuration has auto-save backup configured
# 1 - FAILED: Configuration does not have auto-save backup
# 2 - ERROR: File not found or invalid arguments
#
# REQUIREMENTS:
# - Bash 4.0 or higher
# - Read access to configuration files
# - grep utilities (standard on most Unix/Linux systems)
#
# EXAMPLE VALID CONFIGURATIONS:
# Local disk backup:
# configuration commit auto-save filename disk0:/bkp_asr9k
#
# Remote SFTP backup:
# configuration commit auto-save filename sftp://rtrbkp@192.168.1.100://asr9k/bkp_conf_asr9k

# Check arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 <config_file>"
    exit 1
fi

CONFIG_FILE="$1"

# Check file exists and is readable
if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: File not found: $CONFIG_FILE"
    exit 1
fi

if [ ! -r "$CONFIG_FILE" ]; then
    echo "ERROR: Cannot read file: $CONFIG_FILE"
    exit 1
fi

# Function to check configuration backup auto-save
check_backup_config() {
    # Check for configuration commit auto-save filename
    if grep -q "^configuration[[:space:]]\+commit[[:space:]]\+auto-save[[:space:]]\+filename[[:space:]]\+" "$CONFIG_FILE"; then
        return 0  # Auto-save backup configuration found
    fi
    
    return 1  # No auto-save backup configuration found
}

# Main validation logic
check_backup_config
if [ $? -ne 0 ]; then
    echo "FAILED"
    # Uncomment below line for detailed debugging:
    # echo "FAILED: No configuration commit auto-save found"
    exit 1
fi

# Check passed
echo "PASS"
exit 0