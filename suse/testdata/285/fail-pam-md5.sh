#!/bin/bash
# pam_unix hashes new passwords with MD5.
sed -i 's/^\(password.*pam_unix.so.*\)/\1 md5/' /etc/pam.d/common-password
