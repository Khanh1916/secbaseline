#!/bin/bash

if rpm -q openldap-servers &> /dev/null; then
  echo "FAIL: openldap-servers (slapd) is installed"
  exit 1
fi

echo "PASS: openldap-servers (slapd) is not installed"
exit 0
