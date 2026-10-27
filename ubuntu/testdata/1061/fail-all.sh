#!/bin/bash
# conf.all has no reverse path filtering.
sysctl -qw net.ipv4.conf.all.rp_filter=0 net.ipv4.conf.default.rp_filter=1
