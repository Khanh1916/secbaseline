#!/bin/bash
# PermitRootLogin yes in a drop-in file, read before PermitRootLogin no in sshd_config.
echo 'PermitRootLogin yes' >/etc/ssh/sshd_config.d/60-cis.conf
echo 'PermitRootLogin no' >>/etc/ssh/sshd_config
