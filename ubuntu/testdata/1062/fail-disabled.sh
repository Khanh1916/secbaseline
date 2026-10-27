#!/bin/bash
# SYN cookies are off.
sysctl -qw net.ipv4.tcp_syncookies=0
