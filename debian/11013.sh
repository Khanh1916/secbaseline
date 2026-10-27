#!/bin/bash

# /var/tmp must be a mount of its own or bound to /tmp: a bind mount of /tmp,
# or a symbolic link to /tmp.
info=$(findmnt -kn -o SOURCE,FSTYPE,OPTIONS /var/tmp 2>/dev/null)

if [ -n "$info" ]; then
  echo "$info" | sed 's|^|INFO: /var/tmp: |'
  echo "PASS: /var/tmp is a separate mount or a bind mount"
  exit 0
fi

if [ -L /var/tmp ] && [ "$(readlink -f /var/tmp)" = /tmp ]; then
  echo "PASS: /var/tmp is a symbolic link to /tmp"
  exit 0
fi

echo "FAIL: /var/tmp is neither a separate mount nor bound to /tmp"
exit 1
