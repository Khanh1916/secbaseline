#!/bin/bash

if [ "$(sysctl net.ipv4.tcp_syncookies)" != "1" ]; then
 echo "net.ipv4.tcp_syncookies is not enabled."
 exit 1
fi

echo "TCP SYN cookies are configured."
exit 0

