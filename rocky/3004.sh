#!/bin/bash

if ! findmnt /tmp &> /dev/null; then
 echo "FAIL: /tmp partition is not configured"
 exit 1
fi

echo "PASS: /tmp partition is configured"
exit 0
