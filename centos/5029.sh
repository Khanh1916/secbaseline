#!/bin/bash

if ! grep -i "banner" /etc/issue &> /dev/null; then
  echo "Login banner is not configured."
  exit 1
fi

echo "Login banner is configured."
exit 0
