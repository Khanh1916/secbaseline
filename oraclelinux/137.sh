#!/bin/bash

if rpm -q dhcp-server &> /dev/null; then
  echo "dhcp-server is installed."
  exit 1
fi

echo "dhcp-server is not installed."
exit 0
