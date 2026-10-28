#!/bin/bash
# X11Forwarding no at the top of sshd_config, before the Include.
sed -i '1i X11Forwarding no' /etc/ssh/sshd_config
