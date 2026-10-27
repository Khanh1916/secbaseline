#!/bin/bash
# IPv4 forwarding is on.
sysctl -qw net.ipv4.ip_forward=1 net.ipv6.conf.all.forwarding=0
