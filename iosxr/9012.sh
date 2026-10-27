#!/bin/bash

# DESCRIPTION:
# This script validates Cisco IOS XR configuration files to ensure proper
# password security configuration. All users must use strong encrypted passwords
# with proper password policies and AES encryption for stored passwords.
#
# VALIDATION CRITERIA:
# REQUIRED CONFIGURATIONS:
# - At least one username block; every username block (any user name,
#   including ones with dots) must contain a secret
# - A password policy is valid when it enforces: min-length >= 10,
#   numeric >= 1, lower-case >= 1, upper-case >= 1, special-char >= 1
# - Every username block must use a valid password policy (any of them)
# - Must have "password6 encryption aes" for AES password storage encryption
#
# FORBIDDEN CONFIGURATIONS:
# - No "password 7" (Vigenere cipher) in any user configuration
#
# USAGE:
# ./9012.sh <config_file>
#
# EXIT CODES:
# 0 - PASS: Configuration meets password security requirements
# 1 - FAIL: Configuration does not meet security requirements, or unreadable file
#
# EXAMPLE SECURE CONFIGURATION:
# username cisco
#  group root-lr
#  policy AAA-PASSWORD-POL
#  secret 10 $6$d7nylmgTAv51l...$aRS7NeBE9hBtojfNMt80BDzf...
# !
# aaa password-policy AAA-PASSWORD-POL
#  numeric 1
#  lower-case 1
#  min-length 10
#  upper-case 1
#  special-char 1
# !
# password6 encryption aes

CONFIG_FILE="$1"
if [ -z "$CONFIG_FILE" ] || [ ! -f "$CONFIG_FILE" ] || [ ! -r "$CONFIG_FILE" ]; then
  echo "FAIL"
  exit 1
fi

if awk '
  function at_least(policy, key, minimum) { return ((policy SUBSEP key) in rule) && rule[policy, key] + 0 >= minimum }
  function valid_policy(p) {
    return at_least(p, "min-length", 10) && at_least(p, "numeric", 1) && at_least(p, "lower-case", 1) &&
           at_least(p, "upper-case", 1) && at_least(p, "special-char", 1)
  }

  { sub(/[ \t\r]+$/, "") }
  /^password6 encryption aes$/ { aes = 1 }
  /^ +password 7 / { type7 = 1 }

  /^username [^ ]+$/ { user = $2; users[user] = 1; policy_block = ""; next }
  /^aaa password-policy [^ ]+$/ { policy_block = $3; policies[policy_block] = 1; user = ""; next }
  /^[^ ]/ { user = ""; policy_block = "" }

  user != "" && $1 == "secret" { secret[user] = 1 }
  user != "" && $1 == "policy" { uses[user] = $2 }
  policy_block != "" && NF == 2 { rule[policy_block, $1] = $2 }

  END {
    if (!aes || type7) exit 1
    n = 0
    for (u in users) {
      n++
      if (!(u in secret) || !(u in uses) || !(uses[u] in policies) || !valid_policy(uses[u])) exit 1
    }
    exit (n > 0 ? 0 : 1)
  }
' "$CONFIG_FILE"; then
  echo "PASS"
  exit 0
fi

echo "FAIL"
exit 1
