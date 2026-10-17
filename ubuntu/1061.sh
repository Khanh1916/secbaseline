#!/bin/bash

if [ "$(sysctl -n net.ipv4.conf.all.rp_filter)" != "1" ]; then
  echo "net.ipv4.conf.all.rp_filter is not enabled."
  exit 1
fi

if [ "$(sysctl -n net.ipv4.conf.default.rp_filter)" != "1" ]; then
  echo "net.ipv4.conf.default.rp_filter is not enabled."
  exit 1
fi

echo "RFC Source Route Validation (RP-Filter) is configured."
exit 0
