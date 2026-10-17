#!/bin/bash

rpm -q openldap2-client &>/dev/null

if [ $? -ne 0 ]; then
  echo "PASS: Package openldap-clients is not installed"
  exit 0
else
  echo "FAIL: openldap-clients installed"
  exit 1
fi