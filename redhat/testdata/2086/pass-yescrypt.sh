#!/bin/bash
# yescrypt in login.defs and on pam_unix.
sed -i 's/^ENCRYPT_METHOD.*/ENCRYPT_METHOD YESCRYPT/' /etc/login.defs
sed -i 's/ sha512 / yescrypt /' /etc/pam.d/system-auth /etc/pam.d/password-auth
