#!/bin/bash

min_day=$(grep "^PASS_MIN_DAYS" /etc/login.defs 2>/dev/null | awk '{print $2}')

if [ -n "$min_day" ] && [ "$min_day" -ge 1 ] 2>/dev/null; then
 echo "File /etc/login.defs includes PASS_MIN_DAYS >= 1."
 exit 0
fi

echo "File /etc/login.defs includes PASS_MIN_DAYS = 0."
exit 1
