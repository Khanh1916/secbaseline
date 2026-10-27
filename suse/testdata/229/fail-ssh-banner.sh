#!/bin/bash
# The file sshd shows names the operating system.
echo 'Authorized users only. All activity may be monitored and reported.' | tee /etc/issue /etc/issue.net >/dev/null
. /etc/os-release
echo "$PRETTY_NAME" >/etc/ssh/banner
echo 'Banner /etc/ssh/banner' >>/etc/ssh/sshd_config
