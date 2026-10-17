#!/bin/bash

if [ "$(sysctl net.ipv4.conf.all.accept_source_route)" != "0" ]; then
 echo "net.ipv4.conf.all.accept_source_route is enabled."
 exit 1
fi

if [ "$(sysctl net.ipv6.conf.all.accept_source_route)" != "0" ]; then
 echo "net.ipv6.conf.all.accept_source_route is enabled."
 exit 1
fi

if [ "$(sysctl net.ipv4.conf.default.accept_source_route)" != "0" ]; then
 echo "sysctl net.ipv4.conf.default.accept_source_route is enabled."
 exit 1
fi

if [ "$(sysctl net.ipv6.conf.default.accept_source_route)" != "0" ]; then
 echo "sysctl net.ipv6.conf.default.accept_source_route is enabled."
 exit 1
fi

echo "Source Router Package Acceptance is disabled."
exit 0
