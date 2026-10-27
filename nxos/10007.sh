#!/bin/bash

# DESCRIPTION:
# This script validates Cisco NX-OS configuration files to ensure proper
# authentication is configured for AUX and Console access.
#
# VALIDATION CRITERIA:
# - The "default" and "console" login lists must not use the method "none",
#   neither alone ("aaa authentication login console none") nor as a fallback
#   after server groups ("aaa authentication login console group TACGRP none");
#   "none" lets any username in
# - Methods are matched as words, so a group whose name contains "none" is fine
# - Without these lines NX-OS uses the local user database, which passes
#
# USAGE:
# ./10007.sh <config_file>
#
# SAMPLE CONFIGURATION:
# aaa authentication login default group TACGRP
# aaa authentication login console group TACGRP
#
# EXIT CODES:
# 0 - PASS: Authentication properly configured for AUX and Console
# 1 - FAIL: Authentication disabled for AUX or Console, or unreadable file

CONFIG_FILE="$1"
if [ -z "$CONFIG_FILE" ] || [ ! -f "$CONFIG_FILE" ]; then
  echo "FAIL"
  exit 1
fi

# An empty file (or one holding only comments) is not a configuration: fail
# instead of reporting the settings it lacks as compliant.
if ! grep -qvE '^[[:space:]]*([!#].*)?$' "$CONFIG_FILE"; then
  echo "FAIL"
  exit 1
fi

if awk '
  { sub(/[ \t\r]+$/, "") }
  /^aaa authentication login (default|console) / {
    for (i = 5; i <= NF; i++) if ($i == "none") bad = 1
  }
  END { exit (bad ? 1 : 0) }
' "$CONFIG_FILE"; then
  echo "PASS"
  exit 0
fi

echo "FAIL"
exit 1
