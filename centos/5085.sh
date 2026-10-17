#!/bin/bash

# Check if remember is configured in pwquality.conf
if ! grep "^remember" /etc/security/pwquality.conf &> /dev/null; then
    echo "remember is not configured."
    exit 1
fi

remember_value=$(grep "^remember" /etc/security/pwquality.conf | cut -d= -f2 | tr -d ' ')

if [[ $remember_value -lt 5 ]]; then
    echo "remember is less than 5."
    exit 1
fi

echo "remember=5 or greater is configured."
exit 0
