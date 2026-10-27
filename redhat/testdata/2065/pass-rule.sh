#!/bin/bash
# /etc/hosts.allow allows SSH from one network.
echo 'sshd: 10.0.0.0/8' >>/etc/hosts.allow
