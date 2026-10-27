#!/bin/bash

# DESCRIPTION:
# This script validates Cisco IOS XR configuration files to ensure proper
# exec-timeout configuration is present and meets security standards.
# Administrators should configure EXEC timeout on network devices to automatically
# disconnect idle user sessions after a specified period of inactivity. This practice
# helps enhance security by preventing unauthorized access through potentially abandoned
# sessions by users who have forgotten to log off and terminate their session properly.
#
# VALIDATION CRITERIA:
# - A valid timeout is "exec-timeout <minutes> <seconds>" of more than 0 and at
#   most 5 minutes ("exec-timeout 0 0" disables it)
# - "line default" must have a valid exec-timeout
# - Every line template used by a vty-pool must have a valid exec-timeout:
#   templates do not inherit from "line default", so one without exec-timeout
#   gives its VTY sessions the 10-minute system default
# - Every exec-timeout that is configured (console, templates) must be valid
# - Returns PASS for compliant configurations, FAIL otherwise
#
# USAGE:
# ./9003.sh <config_file>
#
# SAMPLE CONFIGURATIONS:
# line default
#  exec-timeout 5 0
# line console
#  exec-timeout 5 0
# line template SSH-TEMP
#  exec-timeout 5 0
# vty-pool default 0 4 line-template SSH-TEMP
#
# EXIT CODES:
# 0 - PASS: Configuration meets exec-timeout requirements
# 1 - FAIL: Configuration does not meet requirements, or unreadable file

CONFIG_FILE="$1"
if [ -z "$CONFIG_FILE" ] || [ ! -f "$CONFIG_FILE" ]; then
  echo "FAIL"
  exit 1
fi

if awk '
  function valid(block) { return (block in timeout) && timeout[block] > 0 && timeout[block] <= 300 }

  { sub(/[ \t\r]+$/, "") }

  /^vty-pool / {
    template = "default"
    for (i = 3; i < NF; i++) if ($i == "line-template") template = $(i + 1)
    pools[$2] = template
  }

  /^line (console|default)$/ { block = $2; next }
  /^line template / { block = "template " $3; next }
  /^[^ ]/ { block = "" }
  block != "" && /^ +exec-timeout [0-9]+( [0-9]+)?$/ { timeout[block] = $2 * 60 + $3 }

  END {
    if (!valid("default")) exit 1
    for (pool in pools) if (pools[pool] != "default" && !valid("template " pools[pool])) exit 1
    for (block in timeout) if (!valid(block)) exit 1
    exit 0
  }
' "$CONFIG_FILE"; then
  echo "PASS"
  exit 0
fi

echo "FAIL"
exit 1
