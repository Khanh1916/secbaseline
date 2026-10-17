#!/bin/bash

if ! ls -l /etc/pam.d/ &> /dev/null; then
 echo "FAIL: No directory or file displaying"
 exit 1
fi

echo "PASS: PAM is configured successfully"
exit 0
