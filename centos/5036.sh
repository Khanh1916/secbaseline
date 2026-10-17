#!/bin/bash

if systemctl is-enabled avahi-daemon &> /dev/null; then
  echo "avahi-daemon is enabled."
  exit 1
fi

echo "avahi-daemon is disabled or not found."
exit 0
