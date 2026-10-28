#!/bin/bash
# pam_pwhistory remembers 5 passwords.
sed -i '/^password.*pam_unix.so/i password\trequisite\tpam_pwhistory.so remember=5 use_authtok' /etc/pam.d/common-password
