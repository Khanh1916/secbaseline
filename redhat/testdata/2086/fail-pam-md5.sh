#!/bin/bash
# pam_unix hashes new passwords with MD5.
sed -i 's/ sha512 / md5 /' /etc/pam.d/system-auth /etc/pam.d/password-auth
