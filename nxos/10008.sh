#!/bin/bash

# DESCRIPTION:
# This script validates Cisco NX-OS configuration files to ensure proper
# centralized authentication using RADIUS or TACACS+ is configured.
#
# VALIDATION CRITERIA:
# - Must have "aaa authentication login default group <groups>"
# - Must have "aaa authentication login console group <groups>"
# - Every group named on those lines must exist:
#   - "aaa group server radius <GROUP_NAME>" OR
#   - "aaa group server tacacs+ <GROUP_NAME>" OR
#   - the built-in "radius" / "tacacs+" group, when "radius-server host" /
#     "tacacs-server host" servers are configured
# - A trailing fallback method ("none", "local") is not a group; 10007 checks "none"
# - Returns PASS only if all criteria are met
#
# USAGE:
# ./10008.sh <config_file>
#
# SAMPLE CONFIGURATION:
# aaa authentication login default group TACGRP RADGRP
# aaa authentication login console group TACGRP RADGRP
# aaa group server radius RADGRP
#     server 192.168.89.121
# aaa group server tacacs+ TACGRP
#     server 192.168.89.111
#
# EXIT CODES:
# 0 - PASS: Centralized authentication properly configured
# 1 - FAIL: Missing or incorrect centralized authentication, or unreadable file

CONFIG_FILE="$1"
if [ -z "$CONFIG_FILE" ] || [ ! -f "$CONFIG_FILE" ]; then
  echo "FAIL"
  exit 1
fi

# Read the file twice: groups and servers may appear after the login lists.
if awk '
  { sub(/[ \t\r]+$/, "") }

  NR == FNR {
    if ($0 ~ /^aaa group server (radius|tacacs\+) /) groups[$5] = 1
    if ($0 ~ /^radius-server host /) groups["radius"] = 1
    if ($0 ~ /^tacacs-server host /) groups["tacacs+"] = 1
    next
  }

  /^aaa authentication login (default|console) / {
    seen[$4] = 1
    if ($5 != "group") { bad = 1; next }
    named = 0
    for (i = 6; i <= NF; i++) {
      if ($i == "none" || $i == "local") continue
      named++
      if (!($i in groups)) bad = 1
    }
    if (named == 0) bad = 1
  }

  END { exit ((!seen["default"] || !seen["console"] || bad) ? 1 : 0) }
' "$CONFIG_FILE" "$CONFIG_FILE"; then
  echo "PASS"
  exit 0
fi

echo "FAIL"
exit 1
