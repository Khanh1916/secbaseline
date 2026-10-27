#!/bin/bash
# PermitRootLogin no appended to sshd_config, after the shipped PermitRootLogin yes.
echo 'PermitRootLogin no' >>/etc/ssh/sshd_config
