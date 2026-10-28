#!/bin/bash
# IPv6 forwarding is on.
sysctl -qw net.ipv4.ip_forward=0 net.ipv6.conf.all.forwarding=1
