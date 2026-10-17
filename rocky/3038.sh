#!/bin/bash
output=$(rpm -q dhcp-server)

echo "$output"

if [[ "$output" == "package dhcp-server is not installed" ]]; then
	    echo "PASS: dhcp-server is not installed"
	        exit 0
	else
		    echo "FAIL: dhcp-server is installed"
		        exit 1
fi

