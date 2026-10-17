#!/bin/bash

if [ "$(iptables -L -n 2>/dev/null | grep -v "^Chain" | grep -v "^target" | grep -v "^$" | wc -l)" -eq "0" ]; then
  echo "No firewall rules found in iptables"
  exit 1
fi

echo "Firewall rules exist in iptables"
exit 0
