#!/bin/bash

if [ "$(sysctl -n net.ipv4.ip_forward)" != "0" ]; then
  echo "IPv4 IP forwarding is enabled."
  exit 1
fi

echo "IP forwarding is disabled."
exit 0
