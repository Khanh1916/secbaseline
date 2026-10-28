#!/bin/bash
# pam_pwhistory takes remember=24 from pwhistory.conf.
sed -i 's/^\(password.*pam_unix.so.*\)/password requisite pam_pwhistory.so use_authtok\n\1/' /etc/pam.d/common-password
echo 'remember = 24' >>/etc/security/pwhistory.conf
