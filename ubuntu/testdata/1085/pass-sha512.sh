#!/bin/bash
# SHA512 in login.defs and PAM.
sed -i 's/^ENCRYPT_METHOD.*/ENCRYPT_METHOD SHA512/' /etc/login.defs
sed -i 's/pam_unix.so obscure yescrypt/pam_unix.so obscure sha512/' /etc/pam.d/common-password
