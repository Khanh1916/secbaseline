#!/bin/bash

if dpkg -s telnetd 2>/dev/null | grep -q "Status: install ok installed"; then
  echo "FAIL: telnetd is available"
  exit 1
fi

if dpkg -s openbsd-inetd 2>/dev/null | grep -q "Status: install ok installed"; then
 echo "FAIL: openbsd-inetd is available"
 exit 1
fi

echo "PASS: telnetd and openbsd-inetd are uninstalled"
exit 0
