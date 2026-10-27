#!/bin/bash
# Bogus ICMP error responses are logged.
sysctl -qw net.ipv4.icmp_ignore_bogus_error_responses=0
