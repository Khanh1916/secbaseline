#!/bin/bash

# Check if ldap-utils package is installed
if dpkg -s ldap-utils 2>/dev/null | grep -q "Status: install ok installed" ; then
  echo "FAIL: ldap-utils package is installed"
  exit 1
fi

# Check if libnss-ldap package is installed
if dpkg -s libnss-ldap 2>/dev/null | grep -q "Status: install ok installed"; then
  echo "FAIL: libnss-ldap package is installed"
  exit 1
fi

# Check if libpam-ldap package is installed
if dpkg -s libpam-ldap 2>/dev/null | grep -q "Status: install ok installed"; then
  echo "FAIL: libpam-ldap package is installed"
  exit 1
fi

echo "PASS: LDAP client packages are not present"
exit 0
