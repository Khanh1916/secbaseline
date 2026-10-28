#!/bin/bash
# /etc/hosts.deny is writable by everyone.
touch /etc/hosts.deny
chown root:root /etc/hosts.deny
chmod 666 /etc/hosts.deny
