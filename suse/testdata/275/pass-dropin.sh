#!/bin/bash
# PermitRootLogin no in a drop-in file, read before PermitRootLogin yes in sshd_config.
echo 'PermitRootLogin no' >/etc/ssh/sshd_config.d/40-cis.conf
