#!/bin/bash

if grep "X11Forwarding" /etc/ssh/sshd_config 2>/dev/null | grep -E "^X11Forwarding\s+no\b" &>/dev/null; then
  echo "/etc/ssh/sshd_config has X11Forwarding disabled."
  exit 0
fi
  
echo "/etc/ssh/sshd_config does not exist or X11Forwarding is not set to no."
exit 1
