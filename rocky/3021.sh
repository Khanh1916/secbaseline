#!/bin/bash
output=$(sysctl kernel.randomize_va_space)

echo "$output"

value=$(echo "$output" | awk -F'= ' '{print $2}')

if [[ "$value" -eq 2 ]]; then
	    echo "PASS: ASLR is enabled (kernel.randomize_va_space = 2)"
	        exit 0
	else
		    echo "FAIL: ASLR is not fully enabled (kernel.randomize_va_space != 2)"
		        exit 1
fi
