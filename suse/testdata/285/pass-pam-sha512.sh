#!/bin/bash
# pam_unix names sha512.
sed -i 's/^\(password.*pam_unix.so.*\)/\1 sha512/' /etc/pam.d/common-password
