#!/bin/bash
output=$(rpm -q aide)

echo "$output"

if [[ "$output" == aide* ]]; then
	    echo "PASS: aide is installed"
	        exit 0
	else
		    echo "FAIL: aide is not installed"
		        exit 1
fi
