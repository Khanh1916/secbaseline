#!/bin/bash

# Check SSH X11Forwarding configuration
x11_config=$(grep "^X11Forwarding" /etc/ssh/sshd_config 2>/dev/null)

if [ -n "$x11_config" ] && echo "$x11_config" | grep -q "X11Forwarding no"; then
  echo "/etc/ssh/sshd_config has X11Forwarding disabled."
  exit 0
fi

echo "/etc/ssh/sshd_config does not exist or X11Forwarding is not set to no."
exit 1
