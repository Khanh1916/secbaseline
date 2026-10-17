#!/bin/bash
output=$(rpm -q dovecot)

echo "$output"

if [[ "$output" == "package dovecot is not installed" ]]; then
	    echo "PASS: dovecot is not installed"
	        exit 0
	else
		    echo "FAIL: dovecot is installed"
		        exit 1
fi

