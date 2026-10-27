#!/bin/bash

# DESCRIPTION:
# This script validates Cisco IOS XR configuration files to ensure proper
# AAA authentication lockout configuration. The script checks if lockout-time
# and authen-max-attempts are configured in the AAA password policy, and
# verifies that all username accounts use the password policy.
#
# VALIDATION CRITERIA:
# REQUIRED CONFIGURATIONS:
# - A password policy with lockout is one that has both "lockout-time" and
#   "authen-max-attempts"
# - At least one username block, and every username block (any user name,
#   including ones with dots) must reference a policy with lockout (any of them)
#
# USAGE:
# ./9014.sh <config_file>
#
# EXIT CODES:
# 0 - PASS: Configuration has lockout settings and all users use such a policy
# 1 - FAIL: Configuration missing lockout settings or users not using it, or unreadable file
#
# EXAMPLE VALID CONFIGURATION:
# aaa password-policy AAA-PASSWORD-POL
#  lockout-time minutes 30
#  authen-max-attempts 5
# !
# username cisco
#  policy AAA-PASSWORD-POL
# !

CONFIG_FILE="$1"
if [ -z "$CONFIG_FILE" ] || [ ! -f "$CONFIG_FILE" ] || [ ! -r "$CONFIG_FILE" ]; then
  echo "FAIL"
  exit 1
fi

if awk '
  { sub(/[ \t\r]+$/, "") }
  /^username [^ ]+$/ { user = $2; users[user] = 1; policy_block = ""; next }
  /^aaa password-policy [^ ]+$/ { policy_block = $3; user = ""; next }
  /^[^ ]/ { user = ""; policy_block = "" }

  user != "" && $1 == "policy" { uses[user] = $2 }
  policy_block != "" && $1 == "lockout-time" { lockout[policy_block] = 1 }
  policy_block != "" && $1 == "authen-max-attempts" { attempts[policy_block] = 1 }

  END {
    n = 0
    for (u in users) {
      n++
      p = uses[u]
      if (p == "" || !(p in lockout) || !(p in attempts)) exit 1
    }
    exit (n > 0 ? 0 : 1)
  }
' "$CONFIG_FILE"; then
  echo "PASS"
  exit 0
fi

echo "FAIL"
exit 1
