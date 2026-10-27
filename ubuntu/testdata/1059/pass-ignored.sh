#!/bin/bash
# Broadcast echo requests are ignored.
sysctl -qw net.ipv4.icmp_echo_ignore_broadcasts=1
