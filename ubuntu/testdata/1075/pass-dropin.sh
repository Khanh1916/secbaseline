#!/bin/bash
# PermitRootLogin no in a drop-in file.
echo 'PermitRootLogin no' >/etc/ssh/sshd_config.d/60-cis.conf
