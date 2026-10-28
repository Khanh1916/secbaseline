#!/bin/bash
# conf.all accepts secure redirects.
sysctl -qw net.ipv4.conf.all.secure_redirects=1 net.ipv4.conf.default.secure_redirects=0
