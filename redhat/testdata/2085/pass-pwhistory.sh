#!/bin/bash
# pam_pwhistory remembers 24 passwords.
for f in /etc/pam.d/system-auth /etc/pam.d/password-auth; do
  sed -i '/^password.*pam_unix.so/i password    requisite     pam_pwhistory.so use_authtok remember=24' "$f"
done
