#!/bin/bash

# Every account with a password must have to change it within 90 days: its
# maximum password age (field 5 of /etc/shadow) is between 1 and 90. Accounts
# without a usable password hash (locked, or key-only) are not checked.
MAX_DAYS=90

if [ ! -r /etc/shadow ]; then
  echo "FAIL: Cannot read /etc/shadow (run as root)"
  exit 1
fi

bad=$(awk -F: -v max="$MAX_DAYS" '$2 ~ /^\$/ && ($5 !~ /^[0-9]+$/ || $5 + 0 < 1 || $5 + 0 > max) {print $1 " max=" ($5 == "" ? "unset" : $5)}' /etc/shadow)
users=$(awk -F: '$2 ~ /^\$/' /etc/shadow | wc -l)

if [ -n "$bad" ]; then
  echo "$bad" | sed 's/^/INFO: /'
  echo "FAIL: Accounts with a password must expire within $MAX_DAYS days"
  exit 1
fi

echo "PASS: All $users accounts with a password expire within $MAX_DAYS days"
exit 0
