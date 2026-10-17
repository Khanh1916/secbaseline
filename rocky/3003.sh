#!/bin/bash
output=$(modprobe -n -v udf)

echo "$output"
if [[ "$output" == "install /bin/true" ]]; then
	exit 0
else
	exit 1
fi

