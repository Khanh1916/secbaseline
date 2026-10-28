#!/bin/bash
# /etc/hosts.deny belongs to another group.
touch /etc/hosts.deny
chown root:4242 /etc/hosts.deny
chmod 644 /etc/hosts.deny
