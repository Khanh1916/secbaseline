#!/bin/bash

if [ "$(sysctl net.ipv4.conf.all.accept_redirects)" != "0" ]; then
 echo "FAIL: net.ipv4.conf.all.accept_redirects is enabled"
 exit 1
fi

echo "PASS: ICMP Redirect Acceptance is disabled"
exit 0

