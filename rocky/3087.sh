#!/bin/bash

if ! grep -E '^PASS_MAX_DAYS' /etc/login.defs &> /dev/null; then
    echo "PASS_MAX_DAYS is not configured or greater than 90."
    exit 1
fi

pass_max_days_value=$(grep -E '^PASS_MAX_DAYS' /etc/login.defs | awk '{print $2}' | tr -d ' ')

if [[ $pass_max_days_value -gt 90 ]]; then
    echo "PASS_MAX_DAYS is not configured or greater than 90."
    exit 1
fi

echo "PASS_MAX_DAYS 90 or less is configured."
exit 0
