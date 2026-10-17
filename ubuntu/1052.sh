#!/bin/bash

# Check if ldap-utils package is installed
if dpkg -s ldap-utils 2>/dev/null | grep -q "Status: install oke installed" ; then
  echo "ldap-utils package is installed."
  exit 1
fi

# Check if libnss-ldap package is installed
if dpkg -s libnss-ldap 2>/dev/null | grep -q "Status: install oke installed"; then
  echo "libnss-ldap package is installed."
  exit 1
fi

# Check if libpam-ldap package is installed
if dpkg -s libpam-ldap 2>/dev/null | grep -q "Status: install ok installed"; then
  echo "libpam-ldap package is installed."
  exit 1
fi

echo "LDAP client packages are not present."
exit 0
