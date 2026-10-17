#!/bin/bash
aslr_value=$(sysctl -n kernel.randomize_va_space 2>/dev/null)

if [ -z "$aslr_value" ]; then
	echo "FAIL: Could not read kernel.randomize_va_space"
	exit 1
fi

if [ "$aslr_value" -eq 2 ]; then
	echo "PASS: ASLR is fully enabled (kernel.randomize_va_space = 2)"
	exit 0
else
	echo "FAIL: ASLR is not fully enabled (kernel.randomize_va_space = $aslr_value)"
	exit 1
fi
