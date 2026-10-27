#!/bin/bash

# PASS_MAX_DAYS in /etc/login.defs, the maximum password age of new accounts,
# must be between 1 and 90 days.
MAX_DAYS=90

value=$(awk '$1 == "PASS_MAX_DAYS" {v = $2} END {print v}' /etc/login.defs 2>/dev/null)

if ! [[ "$value" =~ ^[0-9]+$ ]] || [ "$value" -lt 1 ] || [ "$value" -gt "$MAX_DAYS" ]; then
  echo "FAIL: PASS_MAX_DAYS must be between 1 and $MAX_DAYS, found ${value:-unset}"
  exit 1
fi

echo "PASS: PASS_MAX_DAYS is $value (at most $MAX_DAYS)"
exit 0
