#!/bin/bash

if grep "ENCRYPT_METHOD" /etc/login.defs 2>/dev/null | grep -E "^ENCRYPT_METHOD\s+SHA512\b" &>/dev/null; then
  echo "PASS: Hashing method for password is SHA512"
  exit 0
fi

echo "FAIL: File /etc/login.defs does not include ENCRYPT_METHOD SHA512"
exit 1
