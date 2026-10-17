#!/bin/bash

if rpm -q openldap-clients &> /dev/null; then
  echo "FAIL: openldap-clients is installed"
  exit 1
fi

echo "PASS: openldap-clients is not installed"
exit 0
