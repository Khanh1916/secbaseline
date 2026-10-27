#!/bin/bash
# pam_unix remembers 5 passwords.
sed -i 's/^\(password.*pam_unix.so.*\)/\1 remember=5/' /etc/pam.d/system-auth /etc/pam.d/password-auth
