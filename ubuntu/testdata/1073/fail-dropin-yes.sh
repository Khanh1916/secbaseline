#!/bin/bash
# X11Forwarding yes in a drop-in file, read before X11Forwarding no in sshd_config.
echo 'X11Forwarding yes' >/etc/ssh/sshd_config.d/60-cis.conf
sed -i 's/^#*X11Forwarding.*/X11Forwarding no/' /etc/ssh/sshd_config
