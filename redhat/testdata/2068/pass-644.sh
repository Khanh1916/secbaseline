#!/bin/bash
# /etc/hosts.deny is 0644 root:root.
touch /etc/hosts.deny
chown root:root /etc/hosts.deny
chmod 644 /etc/hosts.deny
