#!/bin/bash
core_limit=$(ulimit -c)

if [ "$core_limit" = "0" ]; then
	echo "pass: Core dump đã bị giới hạn (ulimit -c = 0)."
	exit 0
else
	echo "fail: Core dump chưa bị giới hạn (ulimit -c = $core_limit)."
	exit 1
fi
