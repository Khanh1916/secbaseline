#!/bin/bash
output=$(ulimit -c)

echo "$output"

if [[ "$output" -eq 0 ]]; then
	    echo "PASS: core dump is disabled (ulimit -c = 0)"
	        exit 0
	else
		    echo "FAIL: core dump is not disabled (ulimit -c != 0)"
		        exit 1
fi
