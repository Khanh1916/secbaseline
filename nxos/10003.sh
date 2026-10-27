#!/bin/bash

# DESCRIPTION:
# This script validates Cisco NX-OS configuration files to ensure proper
# exec-timeout configuration is present and meets security standards.
#
# VALIDATION CRITERIA:
# - "line console" and "line vty" must both have "exec-timeout <minutes>" of
#   1 to 5 minutes; a shorter timeout is stricter and passes
# - A missing section or exec-timeout fails: the NX-OS default is 0, which
#   never disconnects idle sessions
# - "exec-timeout 0" disables the timeout and fails
#
# USAGE:
# ./10003.sh <config_file>
#
# SAMPLE CONFIGURATION:
# line console
#   exec-timeout 5
# line vty
#   exec-timeout 5
#
# EXIT CODES:
# 0 - PASS: Console and VTY have an exec-timeout of at most 5 minutes
# 1 - FAIL: Missing or incorrect exec-timeout configuration, or unreadable file

CONFIG_FILE="$1"
if [ -z "$CONFIG_FILE" ] || [ ! -f "$CONFIG_FILE" ]; then
  echo "FAIL"
  exit 1
fi

if awk '
  function valid(line) { return (line in timeout) && timeout[line] >= 1 && timeout[line] <= 5 }

  { sub(/[ \t\r]+$/, "") }
  /^line (console|vty)$/ { section = $2; next }
  /^[^ ]/ { section = "" }
  section != "" && /^ +exec-timeout [0-9]+$/ { timeout[section] = $2 }

  END { exit ((valid("console") && valid("vty")) ? 0 : 1) }
' "$CONFIG_FILE"; then
  echo "PASS"
  exit 0
fi

echo "FAIL"
exit 1
