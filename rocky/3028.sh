#!/bin/bash
output=$(rpm -q mcstrans)

echo "$output"

if [[ "$output" == "package mcstrans is not installed" ]]; then
	    echo "PASS: mcstrans is not installed"
	        exit 0
	else
		    echo "FAIL: mcstrans is installed"
		        exit 1
fi
