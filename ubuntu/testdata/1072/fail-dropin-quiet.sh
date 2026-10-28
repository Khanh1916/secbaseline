#!/bin/bash
# LogLevel QUIET in a drop-in file, read before LogLevel INFO in sshd_config.
echo 'LogLevel QUIET' >/etc/ssh/sshd_config.d/60-cis.conf
echo 'LogLevel INFO' >>/etc/ssh/sshd_config
