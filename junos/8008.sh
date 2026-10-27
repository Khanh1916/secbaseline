#!/bin/bash

# DESCRIPTION:
# This script validates Junos centralized authentication with RADIUS or
# TACACS+ in a configuration saved in set format
# ("show configuration | display set").
#
# VALIDATION LOGIC:
# 1. Check if configuration file exists and is accessible
# 2. Every active radius-server and tacplus-server has a secret
# 3. The authentication order names radius or tacplus, and at least one
#    active server of that type exists. Both forms are read:
#      set system authentication-order radius
#      set system authentication-order password
#    and
#      set system authentication-order [ radius password ]
# 4. Deactivated statements ("deactivate system ...") do not count
#
# SAMPLE CONFIGURATION:
# set system radius-server 10.255.100.20 port 1812
# set system radius-server 10.255.100.20 secret "$9$..."
# set system tacplus-server 10.255.100.40 secret "$9$..."
# set system authentication-order [ tacplus password ]
#
# USAGE:
# ./8008.sh <config_file>
#
# EXIT CODES:
# 0 - PASS: centralized authentication is configured and every server has a secret
# 1 - FAIL: missing servers, order or secrets, or the file is unreadable

CONFIG="$1"
if [ -z "$CONFIG" ] || [ ! -f "$CONFIG" ]; then
  echo "FAIL"
  exit 1
fi

if awk '
  # A statement is active unless it or a parent is deactivated.
  function active(stmt,   p) {
    for (p in off) if (stmt == p || index(stmt, p " ") == 1) return 0
    return 1
  }

  { sub(/[ \t\r]+$/, "") }
  /^deactivate / { off[substr($0, 12)] = 1; next }

  /^set system (radius|tacplus)-server / {
    server = "system " $3 " " $4
    type[server] = ($3 == "radius-server") ? "radius" : "tacplus"
    if ($5 == "secret") secret[server] = 1
  }

  /^set system authentication-order / {
    for (i = 4; i <= NF; i++) if ($i != "[" && $i != "]") order[$i] = 1
  }

  END {
    if (!active("system authentication-order")) exit 1
    for (server in type) {
      if (!active(server)) continue
      if (!(server in secret) || !active(server " secret")) exit 1
      count[type[server]]++
    }
    if ((("radius" in order) && count["radius"] > 0) || (("tacplus" in order) && count["tacplus"] > 0)) exit 0
    exit 1
  }
' "$CONFIG"; then
  echo "PASS"
  exit 0
fi

echo "FAIL"
exit 1
