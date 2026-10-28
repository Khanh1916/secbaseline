#!/bin/bash
# pam_pwhistory remembers 24 passwords.
sed -i 's/^\(password.*pam_unix.so.*\)/password requisite pam_pwhistory.so remember=24 enforce_for_root use_authtok\n\1/' /etc/pam.d/common-password
