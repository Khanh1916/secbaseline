#!/bin/bash
# /etc/hosts.allow is writable by everyone.
touch /etc/hosts.allow
chown root:root /etc/hosts.allow
chmod 666 /etc/hosts.allow
