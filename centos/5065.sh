#!/bin/bash

if [ -f /etc/hosts.allow ] && cat /etc/hosts.allow | grep -v "^#" | grep -q "[a-zA-Z0-9]"; then
  echo "/etc/hosts.allow exists and contains at least one allow rule."
  exit 0
fi

echo "/etc/hosts.allow does not exist or contains no allow rules."
exit 1
