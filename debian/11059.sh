#!/bin/bash

if [ "$(sysctl -n net.ipv4.icmp_echo_ignore_broadcasts)" != "1" ]; then
 echo "FAIL: net.ipv4.icmp_echo_ignore_broadcasts is not enabled"
 exit 1
fi

echo "PASS: Ignore Broadcast Requests is configured"
exit 0 
