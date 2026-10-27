#!/bin/bash
# X11Forwarding is not set anywhere: the default is no.
sed -i '/^X11Forwarding/d' /etc/ssh/sshd_config
