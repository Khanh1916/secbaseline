#!/bin/bash
# Broadcast echo requests are answered.
sysctl -qw net.ipv4.icmp_echo_ignore_broadcasts=0
