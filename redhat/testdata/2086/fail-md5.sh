#!/bin/bash
# MD5 in login.defs.
sed -i 's/^ENCRYPT_METHOD.*/ENCRYPT_METHOD MD5/' /etc/login.defs
