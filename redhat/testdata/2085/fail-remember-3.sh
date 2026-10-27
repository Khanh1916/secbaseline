#!/bin/bash
# pam_pwhistory remembers only 3 passwords.
for f in /etc/pam.d/system-auth /etc/pam.d/password-auth; do
  sed -i '/^password.*pam_unix.so/i password    requisite     pam_pwhistory.so use_authtok remember=3' "$f"
done
