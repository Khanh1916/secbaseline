#!/bin/bash
if ! command -v getenforce &> /dev/null; then
	echo "FAIL: Command 'getenforce' not found; SELinux may not be installed"
	exit 1
fi

selinux_status=$(getenforce)

if [ "$selinux_status" == "Enforcing" ]; then
	echo "PASS: SELinux is in Enforcing mode"
	exit 0
else
	echo "FAIL: SELinux is in $selinux_status mode; it must be Enforcing"
	exit 1
fi

