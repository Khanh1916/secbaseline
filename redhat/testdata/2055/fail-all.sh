#!/bin/bash
# conf.all sends redirects.
sysctl -qw net.ipv4.conf.all.send_redirects=1 net.ipv4.conf.default.send_redirects=0
