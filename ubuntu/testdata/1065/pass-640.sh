#!/bin/bash
# /etc/hosts.allow is 0640 root:root, stricter than required.
touch /etc/hosts.allow
chown root:root /etc/hosts.allow
chmod 640 /etc/hosts.allow
