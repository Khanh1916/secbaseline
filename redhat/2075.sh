#!/bin/bash

if grep "^MaxAuthTries" /etc/ssh/sshd_config 2>/dev/null | grep -E "^MaxAuthTries\s+[0-4]\b" &>/dev/null; then
  echo "/etc/ssh/sshd_config has MaxAuthTries set to 4 or less."
  exit 0
fi

echo "MaxAuthTries in /etc/ssh/sshd_config is not set to 4 or less."
exit 1
