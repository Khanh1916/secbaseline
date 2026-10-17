#!/bin/bash

if [ ! -f /etc/hosts.deny ]; then
  echo "FAIL: /etc/hosts.deny file does not exist"
  exit 1
fi

stat_output=$(stat /etc/hosts.deny | grep "Access:" | head -1)

if echo "$stat_output" | grep -q "Access: (0640/-rw-r-----)"; then
  echo "PASS: File permissions are 0640"
  exit 0
fi

echo "FAIL: File permissions are not 0640"
exit 1
