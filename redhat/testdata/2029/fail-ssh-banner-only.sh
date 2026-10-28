#!/bin/bash
# sshd shows a warning, but /etc/issue is the default.
echo 'Authorized users only. All activity may be monitored and reported.' >/etc/issue.net
echo 'Banner /etc/issue.net' >>/etc/ssh/sshd_config
