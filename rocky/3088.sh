#!/bin/bash

if chage -l root | grep "Password expires" | grep -q "never"; then
    echo "Password expiry date is not configured."
    exit 1
fi

echo "Password expiry date is configured."
exit 0
