#!/bin/bash
# X11Forwarding yes in sshd_config.
sed -i 's/^#*X11Forwarding.*/X11Forwarding yes/' /etc/ssh/sshd_config
grep -q '^X11Forwarding yes' /etc/ssh/sshd_config || echo 'X11Forwarding yes' >>/etc/ssh/sshd_config
