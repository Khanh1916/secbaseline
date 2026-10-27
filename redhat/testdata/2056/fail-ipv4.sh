#!/bin/bash
# IPv4 conf.all accepts source routes.
sysctl -qw net.ipv4.conf.all.accept_source_route=1 net.ipv4.conf.default.accept_source_route=0 net.ipv6.conf.all.accept_source_route=0 net.ipv6.conf.default.accept_source_route=0
