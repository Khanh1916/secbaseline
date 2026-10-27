#!/bin/bash
# DESCRIPTION:
# This script validates Cisco IOS XR AAA authentication configuration
# following the comprehensive validation logic for centralized authentication
#
# VALIDATION LOGIC:
# 1. Server groups: named groups ("aaa group server radius|tacacs+ <name>"),
#    and the built-in "radius" / "tacacs+" groups when "radius-server host" /
#    "tacacs-server host" servers exist
# 2. A login list is central when it is defined exactly by name and its first
#    method is "group <server group>":
#    "aaa authentication login <list> group <group> [...]"
# 3. "line console" and "line default" MUST contain "login authentication <list>"
#    with a central list
# 4. Every vty-pool's line template other than "default" MUST contain
#    "login authentication <list>" with a central list. Without any vty-pool
#    line, IOS XR uses the default pool with the "default" template
#
# SAMPLE CONFIGURATION:
# aaa group server tacacs+ TACGRP
#  server 192.168.89.111
# !
# aaa authentication login default group TACGRP local
# aaa authentication login VTY-AUTHEN group TACGRP local
# line console
#  login authentication default
# !
# line default
#  login authentication default
# !
# line template SSH-TEMP
#  login authentication VTY-AUTHEN
# !
# vty-pool default 0 4 line-template SSH-TEMP
#
# USAGE:
# ./9008.sh <config_file>
#
# EXIT CODES:
# 0 - PASS: Configuration meets requirements
# 1 - FAIL: Configuration does not meet requirements, or unreadable file

CONFIG_FILE="$1"
if [ -z "$CONFIG_FILE" ] || [ ! -f "$CONFIG_FILE" ]; then
  echo "FAIL"
  exit 1
fi

if awk '
  function central(list,   g) {
    if (!(list in first) || first[list] != "group") return 0
    g = group[list]
    return (g in groups) || (g == "radius" && servers["radius"]) || (g == "tacacs+" && servers["tacacs+"])
  }

  # A line block ("console", "default" or "template <name>") needs an explicit central list.
  function line_central(block) {
    return (block in auth) && central(auth[block])
  }

  { sub(/[ \t\r]+$/, "") }
  /^radius-server host / { servers["radius"] = 1 }
  /^tacacs-server host / { servers["tacacs+"] = 1 }
  /^aaa group server (radius|tacacs\+) / { groups[$5] = 1 }
  /^aaa authentication login / { first[$4] = $5; group[$4] = $6 }

  /^vty-pool / {
    template = "default"
    for (i = 3; i < NF; i++) if ($i == "line-template") template = $(i + 1)
    pools[$2] = template
  }

  /^line (console|default)$/ { block = $2; next }
  /^line template / { block = "template " $3; next }
  /^[^ ]/ { block = "" }
  block != "" && /^ +login authentication / { auth[block] = $3 }

  END {
    if (!line_central("console") || !line_central("default")) exit 1
    for (pool in pools) {
      if (pools[pool] == "default") continue
      if (!line_central("template " pools[pool])) exit 1
    }
    exit 0
  }
' "$CONFIG_FILE"; then
  echo "PASS"
  exit 0
fi

echo "FAIL"
exit 1
