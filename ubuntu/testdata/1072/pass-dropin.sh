#!/bin/bash
# LogLevel VERBOSE in a drop-in file.
echo 'LogLevel VERBOSE' >/etc/ssh/sshd_config.d/60-cis.conf
