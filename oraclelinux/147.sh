#!/bin/bash

inet_interfaces_value=$(postconf -n | grep "^inet_interfaces" | cut -d'=' -f2 | xargs)

if [ "$inet_interfaces_value" = "localhost" ]; then
  echo "PASS: inet_interfaces = localhost"
  exit 0
fi

echo "FAIL: inet_interfaces is not localhost"
exit 1
