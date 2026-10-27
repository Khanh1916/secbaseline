#!/bin/bash
# pam_faillock is commented out.
sed -i 's/^\(auth.*pam_unix.so.*\)/# auth required pam_faillock.so preauth\n\1/' /etc/pam.d/common-auth
