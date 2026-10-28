#!/bin/bash
# /etc/hosts.deny is 0640 root:root, stricter than required.
touch /etc/hosts.deny
chown root:root /etc/hosts.deny
chmod 640 /etc/hosts.deny
