#!/bin/bash
core_limit=$(ulimit -c)

if [ "$core_limit" = "0" ]; then
	echo "PASS: Core dumps are restricted (ulimit -c = 0)"
	exit 0
else
	echo "FAIL: Core dumps are not restricted (ulimit -c = $core_limit)"
	exit 1
fi
