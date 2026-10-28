#!/bin/bash

PACKAGES="dovecot cyrus-imapd"

found=""
for p in $PACKAGES; do
  rpm -q "$p" >/dev/null 2>&1 && found="$found $p"
done

if [ -n "$found" ]; then
  echo "FAIL: An IMAP/POP3 server is installed:$found"
  exit 1
fi

echo "PASS: No IMAP/POP3 server is installed (checked: $PACKAGES)"
exit 0
