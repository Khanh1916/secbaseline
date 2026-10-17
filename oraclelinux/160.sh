#!/bin/bash

if [ "$(sysctl -n net.ipv4.icmp_ignore_bogus_error_responses)" != "1" ]; then
  echo "net.ipv4.icmp_ignore_bogus_error_responses is not enabled."
  exit 1
fi

echo "Bad Error Message protection is configured."
exit 0
