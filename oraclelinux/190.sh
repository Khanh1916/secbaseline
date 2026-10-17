#!/bin/bash

inactive_value=$(grep "^INACTIVE" /etc/login.defs | awk '{print $2}' | tr -d ' ')

if [[ -z "$inactive_value" || $inactive_value -lt 30 ]]; then
    echo "INACTIVE is less than 30 or not configured."
    exit 1
fi

echo "INACTIVE=30 or greater is configured."
exit 0
