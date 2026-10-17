#!/bin/bash

if rpm -q dovecot &> /dev/null; then
  echo "FAIL: dovecot (IMAP, POP3) is installed"
  exit 1
fi

echo "PASS: dovecot (IMAP, POP3) is not installed"
exit 0
