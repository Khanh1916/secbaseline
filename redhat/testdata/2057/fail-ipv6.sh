#!/bin/bash
# IPv6 conf.all accepts redirects.
sysctl -qw net.ipv4.conf.all.accept_redirects=0 net.ipv4.conf.default.accept_redirects=0 net.ipv6.conf.all.accept_redirects=1 net.ipv6.conf.default.accept_redirects=0
