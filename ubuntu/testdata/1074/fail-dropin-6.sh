#!/bin/bash
# MaxAuthTries 6 in a drop-in file, read before MaxAuthTries 4 in sshd_config.
echo 'MaxAuthTries 6' >/etc/ssh/sshd_config.d/60-cis.conf
echo 'MaxAuthTries 4' >>/etc/ssh/sshd_config
