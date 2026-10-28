#!/bin/bash

# /etc/hosts.allow must belong to root:root with mode 0644 or stricter.
FILE=/etc/hosts.allow
MAX_MODE=0644

if [ ! -e "$FILE" ]; then
  echo "FAIL: $FILE does not exist"
  exit 1
fi

read -r mode owner group < <(stat -Lc '%a %U %G' "$FILE")
echo "INFO: $FILE: mode $mode, owner $owner:$group"

if [ "$owner" != root ] || [ "$group" != root ]; then
  echo "FAIL: $FILE must belong to root:root, not $owner:$group"
  exit 1
fi

if [ $((8#$mode & ~8#$MAX_MODE & 8#7777)) -ne 0 ]; then
  echo "FAIL: $FILE has mode $mode; it must be $MAX_MODE or stricter"
  exit 1
fi

echo "PASS: $FILE is $mode root:root ($MAX_MODE or stricter)"
exit 0
