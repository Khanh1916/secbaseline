#!/bin/bash

# CIS: accounts are disabled at most 30 days after their password expires.
# Both the useradd default for new accounts and every existing account that
# has a password must use an INACTIVE value between 0 and 30 (-1 or unset
# means never disabled).
MAX_INACTIVE=30

# useradd reads INACTIVE from /etc/default/useradd; /etc/login.defs has no such setting.
inactive_value=$(useradd -D 2>/dev/null | awk -F= '$1 == "INACTIVE" {print $2}')
if [ -z "$inactive_value" ] && [ -f /etc/default/useradd ]; then
  inactive_value=$(awk -F= '/^[[:space:]]*INACTIVE[[:space:]]*=/ {v = $2; gsub(/[[:space:]]/, "", v)} END {print v}' /etc/default/useradd)
fi
echo "INFO: useradd default INACTIVE=${inactive_value:-unset}"

if grep -qE '^[[:space:]]*INACTIVE' /etc/login.defs 2>/dev/null; then
  echo "INFO: INACTIVE in /etc/login.defs is ignored by useradd; set it with useradd -D -f $MAX_INACTIVE"
fi

if ! [[ "$inactive_value" =~ ^[0-9]+$ ]] || [ "$inactive_value" -gt "$MAX_INACTIVE" ]; then
  echo "FAIL: Default INACTIVE must be between 0 and $MAX_INACTIVE days, found ${inactive_value:-unset}"
  exit 1
fi

if [ ! -r /etc/shadow ]; then
  echo "FAIL: Cannot read /etc/shadow to check INACTIVE for existing users (run as root)"
  exit 1
fi

# Field 7 of /etc/shadow is the per-account INACTIVE value; only accounts with a
# usable password hash are checked.
bad_users=$(awk -F: -v max="$MAX_INACTIVE" '$2 ~ /^\$/ && ($7 !~ /^[0-9]+$/ || $7 + 0 > max) {print $1 " INACTIVE=" ($7 == "" ? "unset" : $7)}' /etc/shadow)

if [ -n "$bad_users" ]; then
  echo "$bad_users" | sed 's/^/INFO: /'
  echo "FAIL: Users with a password must have INACTIVE between 0 and $MAX_INACTIVE days"
  exit 1
fi

echo "PASS: INACTIVE is between 0 and $MAX_INACTIVE days for new accounts and every user with a password"
exit 0
