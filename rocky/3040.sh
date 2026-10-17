#!/bin/bash

if rpm -q bind &> /dev/null || rpm -q unbound &> /dev/null; then
  echo "FAIL: DNS server packages (bind9 or unbound) are installed"
  exit 1
fi

echo "PASS: DNS server packages (bind9 or unbound) are not installed"
exit 0
