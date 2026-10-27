#!/bin/bash
# ENCRYPT_METHOD is commented out: DES.
sed -i 's/^ENCRYPT_METHOD/# ENCRYPT_METHOD/' /etc/login.defs
