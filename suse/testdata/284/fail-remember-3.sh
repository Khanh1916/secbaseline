#!/bin/bash
# pam_unix remembers only 3 passwords.
sed -i 's/^\(password.*pam_unix.so.*\)/\1 remember=3/' /etc/pam.d/common-password
