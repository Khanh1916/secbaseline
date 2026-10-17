#!/bin/bash

if dpkg -s telnetd 2>/dev/null | grep -q "Status: install ok installed"; then
  echo "telnetd is available"
  exit 1
fi

if dpkg -s openbsd-inetd 2>/dev/null | grep -q "Status: install ok installed"; then
 echo "openbsd-inetd is available"
 exit 1
fi

echo "telnetd and openbsd-inetd are uninstalled"
exit 0
