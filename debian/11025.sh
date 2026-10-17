#!/bin/bash
if ! command -v getenforce &>/dev/null; then
	echo "FAIL: Command 'getenforce' not found; SELinux may not be installed"
	exit 1
fi

selinux_mode=$(getenforce)

if [[ "$selinux_mode" == "Enforcing" || "$selinux_mode" == "Permissive" ]]; then
	echo "PASS: SELinux is in $selinux_mode mode"
	exit 0
else
	echo "FAIL: SELinux is in $selinux_mode mode"
	exit 1
fi

