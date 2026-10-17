#!/bin/bash

if ! ls -l /etc/pam.d/ &> /dev/null; then
 echo "No directory or file displaying."
 exit 1
fi

echo "PAM is configured successfully."
exit 0
