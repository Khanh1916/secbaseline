#!/bin/bash
# conf.default has no reverse path filtering.
sysctl -qw net.ipv4.conf.all.rp_filter=1 net.ipv4.conf.default.rp_filter=0
