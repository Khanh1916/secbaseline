#!/bin/bash
# /etc/hosts.allow belongs to another group.
touch /etc/hosts.allow
chown root:4242 /etc/hosts.allow
chmod 644 /etc/hosts.allow
