#!/bin/bash

if [ "$(sysctl net.ipv4.conf.all.send_redirects)" != "0" ]; then
 echo "FAIL: net.ipv4.conf.all.send_redirects is enabled"
 exit 1
fi

echo "PASS: Sending of packet redirects is disabled"
exit 0 

