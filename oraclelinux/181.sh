#!/bin/bash

# Check if pam_tally2 is configured in system-auth
if ! grep pam_tally2 /etc/pam.d/system-auth &> /dev/null; then
    echo "pam_tally2 module is not configured."
    exit 1
fi

echo "pam_tally2 module is properly configured."
exit 0
