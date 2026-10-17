#!/bin/bash

# Check /etc/hosts.deny configuration
if [ ! -f /etc/hosts.deny ]; then
  echo "File does not exist."
  exit 1
fi

hosts_deny_content=$(cat /etc/hosts.deny)

if echo "$hosts_deny_content" | grep -q "^ALL: ALL"; then
  echo "File blocks all connections."
  exit 0
fi

echo "File empty or does not block all connections."
exit 1
