#!/bin/bash
if ! command -v sestatus &>/dev/null; then
	echo "FAIL: Command 'sestatus' not found; SELinux may not be installed"
	exit 1
fi

selinux_status=$(sestatus 2>/dev/null | grep "SELinux status:")

if echo "$selinux_status" | grep -q "enabled"; then
	echo "PASS: SELinux is installed and enabled (SELinux status: enabled)"
	exit 0
else
	echo "FAIL: SELinux is installed but disabled (SELinux status: disabled)"
	exit 1
fi

