#!/bin/bash

output=$(modprobe -n -v cramfs 2>/dev/null)

if echo "$output" | grep "install /bin/true"; then
 echo "PASS: cramfs module is disabled"
 exit 0
fi

echo "FAIL: cramfs module can be loaded"
exit 1
