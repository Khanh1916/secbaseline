#!/bin/bash

if ! grep "PermitRootLogin" /etc/ssh/sshd_config 2>/dev/null | grep -q "^[[:space:]]*PermitRootLogin[[:space:]]\+no"; then
  echo "PermitRootLogin is not disabled (not set to 'no' or commented out)"
  exit 1
fi

echo "PermitRootLogin is properly disabled"
exit 0
