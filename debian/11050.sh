#!/bin/bash

if dpkg -s rsh-client 2>/dev/null | grep -q "Status: install ok installed"; then
 echo "FAIL: rsh-client package is installed"
 exit 1
fi

if dpkg -s rsh-server 2>/dev/null | grep -q "Status: install ok installed"; then
 echo "FAIL: rsh-server package is installed"
 exit 1
fi

echo "PASS: rsh packages are not present"
exit 0
