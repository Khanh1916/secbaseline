#!/bin/bash

# DESCRIPTION:
# This script validates network device time zone and NTP synchronization configuration
# following requirements for local time setting and time synchronization with NTP servers
#
# VALIDATION LOGIC:
# 1. Check if configuration file exists and is accessible
# 2. Validate system time-zone is set to Asia/Saigon
# 3. Verify at least one NTP server is configured
# 4. Ensure proper time synchronization setup for accurate logging and operations
#
# STRICT VALIDATION REQUIREMENTS:
# - Set local time corresponding to "Asia/Saigon" time zone
# - Synchronize time with NTP server for accurate timekeeping
# - System time-zone must be explicitly configured as Asia/Saigon
# - At least one NTP server must be configured for time synchronization
# - Proper time configuration is essential for logging and security operations
#
# SAMPLE CONFIGURATION:
# set system time-zone Asia/Saigon
# set system ntp server 0.vn.pool.ntp.org
# set system ntp server 1.asia.pool.ntp.org
# set system ntp server 2.asia.pool.ntp.org
#
# USAGE:
# ./8009.sh <config_file>
#
# EXIT CODES:
# 0 - PASS: Has "set system time-zone Asia/Saigon" and at least one "set system ntp server"
# 1 - FAILED: Missing time-zone Asia/Saigon or NTP server configuration

# Check Junos config for time-zone and NTP
# PASS if has "set system time-zone Asia/Saigon" and at least one "set system ntp server ..."

if [ $# -ne 1 ]; then
    echo "Usage: $0 <junos_config_file>"
    exit 1
fi

CONFIG="$1"
[ ! -f "$CONFIG" ] && echo "FAILED" && exit 1

# Check time-zone
if ! grep -qE "^set system time-zone Asia/Saigon" "$CONFIG"; then
    echo "FAILED"
    exit 1
fi

# Check NTP server
if ! grep -qE "^set system ntp server " "$CONFIG"; then
    echo "FAILED"
    exit 1
fi

echo "PASS"