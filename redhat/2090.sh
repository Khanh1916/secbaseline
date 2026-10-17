#!/bin/bash

warn_age_value=$(grep -E "^PASS_WARN_AGE" /etc/login.defs 2>/dev/null | awk '{print $2}')

if [ -n "$warn_age_value" ] && [ "$warn_age_value" -ge 7 ] 2>/dev/null; then
  echo "File /etc/login.defs includes PASS_WARN_AGE >= 7."
  exit 0
fi

echo "File /etc/login.defs includes PASS_WARN_AGE <7 or not found."
exit 1

