#!/bin/bash
# IPv4 and IPv6 forwarding are off.
sysctl -qw net.ipv4.ip_forward=0 net.ipv6.conf.all.forwarding=0
