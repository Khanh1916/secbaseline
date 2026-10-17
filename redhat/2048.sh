#!/bin/bash

inet_interfaces_value=$(postconf -n | grep "^inet_interfaces" | cut -d'=' -f2 | xargs)

if [ "$inet_interfaces_value" = "localhost" ]; then
  echo "inet_interfaces = localhost"
  exit 0
fi

echo "inet_interfaces is not localhost"
exit 1
