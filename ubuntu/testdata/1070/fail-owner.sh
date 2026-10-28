#!/bin/bash
# sshd_config belongs to another user (uid 4242).
chown 4242 /etc/ssh/sshd_config
chmod 600 /etc/ssh/sshd_config
