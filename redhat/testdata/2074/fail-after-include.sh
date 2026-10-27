#!/bin/bash
# X11Forwarding no at the end of sshd_config, after 50-redhat.conf set yes.
echo 'X11Forwarding no' >>/etc/ssh/sshd_config
