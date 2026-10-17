#!/bin/bash

# sysctl net...martians return "net...martians = 1" not just "1"
if [ "$(sysctl -n net.ipv4.conf.all.log_martians)" != "1" ]; then
  echo "net.ipv4.conf.all.log_martians is not enabled."
  exit 1
fi

if [ "$(sysctl -n net.ipv4.conf.default.log_martians)" != "1" ]; then
  echo "net.ipv4.conf.default.log_martians is not enabled."
  exit 1
fi

echo "Martian packets logging is properly configured."
exit 0
