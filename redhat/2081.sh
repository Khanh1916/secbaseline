#!/bin/bash

# Check if auditd service is enabled
if ! systemctl is-enabled auditd &> /dev/null; then
    echo "auditd service is disabled or not found."
    exit 1
fi

# Check if auditd service is active
if ! systemctl is-active auditd &> /dev/null; then
    echo "auditd service is not running."
    exit 1
fi

echo "auditd service is enabled and active."
exit 0
