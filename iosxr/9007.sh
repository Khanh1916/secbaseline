#!/bin/bash

# DESCRIPTION:
# This script validates Cisco IOS XR configuration files to ensure proper
# authentication configuration on all line interfaces (console, default, template).
# While IOS XR requires authentication by default, this script enforces additional
# security with secret or login authentication configuration.
#
# VALIDATION CRITERIA:
# - At least one "line console", "line default" or "line template <name>" block
# - Every such block has a "secret", or a "login authentication <list>" whose
#   list authenticates:
#   * a list defined with "aaa authentication login <list> <methods>" must not
#     start with the method "none"
#   * an undefined "default" list falls back to the local user database
#   * an undefined named list fails
#
# USAGE:
# ./9007.sh <config_file>
#
# EXIT CODES:
# 0 - PASS: All line configurations have proper authentication
# 1 - FAIL: Some line configurations missing authentication, or unreadable file
#
# EXAMPLE VALID CONFIGURATION:
# aaa authentication login default group tacacs+ local
# line console
#  login authentication default
# !
# line template VTY-TEMP
#  secret 10 $6$...
# !

CONFIG_FILE="$1"
if [ -z "$CONFIG_FILE" ] || [ ! -f "$CONFIG_FILE" ] || [ ! -r "$CONFIG_FILE" ]; then
  echo "FAIL"
  exit 1
fi

if awk '
  function authenticated(block,   list) {
    if (secret[block]) return 1
    if (!(block in auth)) return 0
    list = auth[block]
    if (list in methods) return methods[list] != "none"
    return list == "default"
  }

  { sub(/[ \t\r]+$/, "") }
  /^aaa authentication login / { methods[$4] = $5 }

  /^line (console|default)$/ { block = $2; seen[block] = 1; next }
  /^line template / { block = "template " $3; seen[block] = 1; next }
  /^[^ ]/ { block = "" }

  block != "" && /^ +secret / { secret[block] = 1 }
  block != "" && /^ +login authentication / { auth[block] = $3 }

  END {
    n = 0
    for (block in seen) {
      n++
      if (!authenticated(block)) exit 1
    }
    exit (n > 0 ? 0 : 1)
  }
' "$CONFIG_FILE"; then
  echo "PASS"
  exit 0
fi

echo "FAIL"
exit 1
