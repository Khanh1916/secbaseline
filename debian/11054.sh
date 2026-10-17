#!/bin/bash

if [ "$(sysctl net.ipv4.conf.all.send_redirects)" != "0" ]; then
 echo "net.ipv4.conf.all.send_redirects is enabled."
 exit 1
fi

if [ "$(sysctl net.ipv4.conf.default.send_redirects)" != "0" ]; then
 echo "net.ipv4.conf.default.send_redirects is enabled."
 exit 1
fi

echo "All network redirects is disabled"
exit 0 
