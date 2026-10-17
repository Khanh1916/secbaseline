#!/bin/bash

if dpkg -s nis 2>/dev/null | grep -q "Status: install ok installed"; then
 echo "NIS server is available"
 exit 1
fi

echo "NIS is uninstalled"
exit 0
