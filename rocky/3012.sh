#!/bin/bash

if ! findmnt /var &> /dev/null; then
 echo "FAIL: /var partition is not configured"
 exit 1
fi

echo "PASS: /var partition is configured"
exit 0
