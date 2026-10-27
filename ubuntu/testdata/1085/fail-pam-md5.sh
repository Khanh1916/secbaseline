#!/bin/bash
# PAM hashes new passwords with MD5.
sed -i 's/pam_unix.so obscure yescrypt/pam_unix.so obscure md5/' /etc/pam.d/common-password
