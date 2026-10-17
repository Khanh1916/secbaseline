#!/bin/bash

if systemctl is-enabled firewalld &> /dev/null; then
  firewall_status=$(systemctl is-enabled firewalld)
  if [ "$firewall_status" = "enabled" ]; then
    echo "Firewall (UFW or Iptables) is enabled."
    exit 0
  fi
fi

echo "Firewall is disabled or not found."
exit 1
