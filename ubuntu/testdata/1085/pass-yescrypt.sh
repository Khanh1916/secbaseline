#!/bin/bash
# yescrypt in login.defs and PAM.
sed -i 's/^ENCRYPT_METHOD.*/ENCRYPT_METHOD YESCRYPT/' /etc/login.defs
