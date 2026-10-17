#!/bin/bash

if [ "$(sysctl -n net.ipv4.ip_forward)" != "0" ]; then
  echo "FAIL: IPv4 IP forwarding is enabled"
  exit 1
fi

if [ "$(sysctl -n net.ipv6.conf.all.forwarding)" != "0" ]; then
  echo "FAIL: IPv6 IP forwarding is enabled"
  exit 1
fi

echo "PASS: IP forwarding is disabled"
exit 0
