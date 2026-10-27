#!/bin/bash
# X11Forwarding no in a drop-in file read before 50-redhat.conf.
echo 'X11Forwarding no' >/etc/ssh/sshd_config.d/40-cis.conf
