#!/bin/bash

if rpm -q openldap-clients &> /dev/null; then
  echo "openldap-clients is installed."
  exit 1
fi

echo "openldap-clients is not installed."
exit 0
