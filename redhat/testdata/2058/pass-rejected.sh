#!/bin/bash
# Secure redirects are rejected.
sysctl -qw net.ipv4.conf.all.secure_redirects=0 net.ipv4.conf.default.secure_redirects=0
