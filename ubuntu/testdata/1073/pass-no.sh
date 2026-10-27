#!/bin/bash
# X11Forwarding no in sshd_config.
sed -i 's/^#*X11Forwarding.*/X11Forwarding no/' /etc/ssh/sshd_config
grep -q '^X11Forwarding no' /etc/ssh/sshd_config || echo 'X11Forwarding no' >>/etc/ssh/sshd_config
