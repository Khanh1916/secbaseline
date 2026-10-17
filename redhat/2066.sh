#!/bin/bash

if [ ! -f /etc/hosts.allow ]; then
  echo "/etc/hosts.allow file does not exist."
  exit 1
fi

stat_output=$(stat /etc/hosts.allow | grep "Access:" | head -1)

if echo "$stat_output" | grep -q "Access: (0640/-rw-r-----)"; then
  echo "File permissions are 0640."
  exit 0
fi

echo "File permissions are not 0640."
exit 1
