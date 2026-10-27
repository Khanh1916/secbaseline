#!/bin/bash

# Cisco IOS-XE Configuration Authentication Validation Script
#
# Purpose: Validate that the console and auxiliary lines require authentication
# Input: Configuration file path as argument
# Output: PASS or FAIL
#
# Usage: ./7007.sh <config_file>
# Example: ./7007.sh running-config.txt
#
# Validation Logic:
# 1. With "aaa new-model", lines authenticate through AAA login method lists
#    and line passwords are ignored:
#    - A line uses the list named by "login authentication <list>", otherwise
#      the "default" list
#    - The list must be defined ("aaa authentication login <list> <methods>")
#      and its first method must not be "none"
#    - Without a default list IOS lets console logins in without any check,
#      while other lines fall back to the local user database
#
# 2. Without "aaa new-model", a line needs "login local", or "login" together
#    with a line "password"
#
# - No line con block -> FAIL (IOS XE always lists line con 0)
# - No line aux block -> not applicable (many platforms have no AUX port)
#
# Return Codes:
# 0 = PASS (console and auxiliary lines require authentication)
# 1 = FAIL (missing or incomplete authentication, or unreadable file)

config_file="$1"

if [ -z "$config_file" ] || [ ! -f "$config_file" ]; then
  echo "FAIL"
  exit 1
fi

if awk '
  function authenticated(type,   list) {
    if (aaa) {
      list = (type in auth_list) ? auth_list[type] : "default"
      if (!(list in methods)) return list == "default" && type != "con"
      return methods[list] != "none"
    }
    return login_local[type] || (login[type] && password[type])
  }

  /^aaa new-model([ \t]|$)/ { aaa = 1 }
  /^aaa authentication login / { methods[$4] = $5 }

  /^line (con|aux) / { type = $2; seen[type] = 1; next }
  /^[^ ]/ { type = "" }

  type != "" && /^ +login authentication / { auth_list[type] = $3 }
  type != "" && /^ +login local([ \t]|$)/ { login_local[type] = 1 }
  type != "" && /^ +login[ \t]*$/ { login[type] = 1 }
  type != "" && /^ +password / { password[type] = 1 }

  END {
    if (!seen["con"] || !authenticated("con")) exit 1
    if (seen["aux"] && !authenticated("aux")) exit 1
    exit 0
  }
' "$config_file"; then
  echo "PASS"
  exit 0
fi

echo "FAIL"
exit 1
