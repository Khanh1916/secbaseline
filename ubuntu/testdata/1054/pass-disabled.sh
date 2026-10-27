#!/bin/bash
# Redirects are not sent.
sysctl -qw net.ipv4.conf.all.send_redirects=0 net.ipv4.conf.default.send_redirects=0
