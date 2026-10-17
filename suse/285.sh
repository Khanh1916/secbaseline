#!/bin/bash

if ! grep "^ENCRYPT_METHOD.*SHA512" /etc/login.defs &> /dev/null; then
    echo "FAIL: ENCRYPT_METHOD is not configured or not SHA512"
    exit 1
fi

echo "PASS: ENCRYPT_METHOD SHA512 is configured"
exit 0
