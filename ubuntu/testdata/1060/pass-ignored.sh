#!/bin/bash
# Bogus ICMP error responses are ignored.
sysctl -qw net.ipv4.icmp_ignore_bogus_error_responses=1
