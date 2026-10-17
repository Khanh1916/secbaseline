#!/bin/bash

if [ "$(sysctl net.ipv4.conf.all.accept_redirects)" != "0" ]; then
 echo "FAIL: net.ipv4.conf.all.accept_redirects is enabled"
 exit 1
fi

if [ "$(sysctl net.ipv6.conf.all.accept_redirects)" != "0" ]; then
 echo "FAIL: net.ipv6.conf.all.accept_redirects is enabled"
 exit 1
fi

if [ "$(sysctl net.ipv4.conf.default.accept_redirects)" != "0" ]; then
 echo "FAIL: sysctl net.ipv4.conf.default.accept_redirects is enabled"
 exit 1
fi

if [ "$(sysctl net.ipv6.conf.default.accept_redirects)" != "0" ]; then
 echo "FAIL: sysctl net.ipv6.conf.default.accept_redirects is enabled"
 exit 1
fi

echo "PASS: ICMP Redirect Acceptance is disabled"
exit 0
