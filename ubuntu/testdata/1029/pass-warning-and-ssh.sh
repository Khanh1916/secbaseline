#!/bin/bash
# /etc/issue and /etc/issue.net hold a warning that sshd shows too.
echo 'Authorized users only. All activity may be monitored and reported.' | tee /etc/issue /etc/issue.net >/dev/null
echo 'Banner /etc/issue.net' >>/etc/ssh/sshd_config
