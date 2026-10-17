#!/bin/bash

if [ "$(sysctl net.ipv4.tcp_syncookies)" != "1" ]; then
 echo "FAIL: net.ipv4.tcp_syncookies is not enabled"
 exit 1
fi

echo "PASS: TCP SYN cookies are configured"
exit 0

