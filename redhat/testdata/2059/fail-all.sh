#!/bin/bash
# conf.all does not log martians.
sysctl -qw net.ipv4.conf.all.log_martians=0 net.ipv4.conf.default.log_martians=1
