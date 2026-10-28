#!/bin/bash
# pam_pwhistory takes remember=24 from pwhistory.conf.
for f in /etc/pam.d/system-auth /etc/pam.d/password-auth; do
  sed -i '/^password.*pam_unix.so/i password    requisite     pam_pwhistory.so use_authtok' "$f"
done
echo 'remember = 24' >>/etc/security/pwhistory.conf
