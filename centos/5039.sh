#!/bin/bash

if rpm -q openldap-servers &> /dev/null; then
  echo "openldap-servers (slapd) is installed."
  exit 1
fi

echo "openldap-servers (slapd) is not installed."
exit 0
