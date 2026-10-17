#!/bin/bash
if ! command -v sestatus &>/dev/null; then
	echo "FAIL: Command 'sestatus' not found; SELinux may not be installed"
	exit 1
fi

policy_info=$(sestatus 2>/dev/null | grep "Loaded policy name:")

if [ -z "$policy_info" ]; then
	echo "FAIL: No loaded SELinux policy found"
	exit 1
else
	echo "PASS: SELinux policy in use: $policy_info"
	exit 0
fi
