#!/bin/bash

if [ "$(stat -c '%a %U %G' /etc/hosts.allow 2>/dev/null)" != "644 root root" ]; then
 echo "FAIL: /etc/hosts.allow permissions are not set to '644 root root'"
 exit 1
fi

echo "PASS: /etc/hosts.allow permissions are configured"
exit 0
