#!/bin/bash

if ! systemctl is-enabled ntpd &> /dev/null; then
  echo "ntpd service is not enabled."
  exit 1
fi

echo "ntpd service is enabled."
exit 0
