#!/bin/bash
# /etc/hosts.allow is 0644 root:root.
touch /etc/hosts.allow
chown root:root /etc/hosts.allow
chmod 644 /etc/hosts.allow
