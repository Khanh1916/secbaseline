#!/bin/bash

# DESCRIPTION:
# This script validates that a login banner (the warning shown before the
# login prompt) is configured, as "banner login" on IOS XE and IOS XR and
# "banner motd" on NX-OS
#
# VALIDATION LOGIC:
# 1. Check if configuration file exists and is accessible
# 2. "set system login message <text>" must be present: Junos shows it before
#    the login prompt. "set system login announcement" is shown only after a
#    successful login, so it does not count as the login banner
# 3. A deactivated message ("deactivate system login message", or a
#    deactivated parent) does not count
#
# SAMPLE CONFIGURATION:
# set system login message "Authorized access only. Activity is monitored."
#
# USAGE:
# ./8002.sh <config_file>
#
# EXIT CODES:
# 0 - PASS: Login message is configured
# 1 - FAIL: Login message is missing or deactivated

CONFIG_FILE="$1"
if [ -z "$CONFIG_FILE" ] || [ ! -f "$CONFIG_FILE" ]; then
  echo "FAIL"
  exit 1
fi

if awk '
  { sub(/[ \t\r]+$/, "") }
  /^set system login message [^ ]/ { message = 1 }
  /^deactivate (system|system login|system login message)$/ { deactivated = 1 }
  END { exit ((message && !deactivated) ? 0 : 1) }
' "$CONFIG_FILE"; then
  echo "PASS"
  exit 0
fi

echo "FAIL"
exit 1
