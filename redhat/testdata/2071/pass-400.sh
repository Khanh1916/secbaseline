#!/bin/bash
# sshd_config is 0400 root:root, stricter than required.
chown root:root /etc/ssh/sshd_config
chmod 400 /etc/ssh/sshd_config
