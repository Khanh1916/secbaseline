#!/bin/bash

if [ "$(sysctl net.ipv4.conf.all.accept_source_route)" != "0" ]; then
 echo "FAIL: net.ipv4.conf.all.accept_source_route is enabled"
 exit 1
fi

echo "PASS: Source-routed packet acceptance is disabled"
exit 0


