#!/bin/bash

if [ "$(sysctl net.ipv4.conf.all.secure_redirects)" != "0" ]; then
 echo "net.ipv4.conf.all.secure_redirects is enabled."
 exit 1
fi

echo "Secure ICMP Redirect Acceptance is disabled."
exit 0
