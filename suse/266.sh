#!/bin/bash

# Check /etc/hosts.deny configuration
if [ ! -f /etc/hosts.deny ]; then
  echo "FAIL: File does not exist"
  exit 1
fi

hosts_deny_content=$(cat /etc/hosts.deny)

if echo "$hosts_deny_content" | grep -q "^ALL: ALL"; then
  echo "PASS: File blocks all connections"
  exit 0
fi

echo "FAIL: File empty or does not block all connections"
exit 1
