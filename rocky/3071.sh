#!/bin/bash

if [ ! -f /etc/ssh/sshd_config ]; then
  echo "FAIL: /etc/ssh/sshd_config file does not exist"
  exit 1
fi

stat_output=$(stat /etc/ssh/sshd_config | grep "Access:" | head -1)

if echo "$stat_output" | grep -q "Access: (0600/-rw-------)"; then
  echo "PASS: File permissions are 0600"
  exit 0
fi

echo "FAIL: File permissions are not 0600"
exit 1
