#!/bin/bash
output_bind=$(rpm -q bind)
output_unbound=$(rpm -q unbound)

echo "$output_bind"
echo "$output_unbound"

if [[ "$output_bind" == "package bind is not installed" && "$output_unbound" == "package unbound is not installed" ]]; then
	    echo "PASS: bind and unbound are not installed"
	        exit 0
	else
		    echo "FAIL: bind or unbound is installed"
		        exit 1
fi

