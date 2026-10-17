#!/bin/bash

inactive_value=$(grep "^INACTIVE" /etc/login.defs 2>/dev/null | awk '{print $2}')

if [ -n "$inactive_value" ] && [ "$inactive_value" -ge 30 ] 2>/dev/null; then
  echo "INACTIVE>=30"
  exit 0
fi

echo "INACTIVE<30"
exit 1
