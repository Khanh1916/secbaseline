#!/bin/bash
# MaxAuthTries 3 in a drop-in file.
echo 'MaxAuthTries 3' >/etc/ssh/sshd_config.d/60-cis.conf
