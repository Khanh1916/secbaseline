#!/bin/bash

output=$(modprobe -n -v squashfs 2>/dev/null)

if echo "$output" | grep "install /bin/true"; then
 echo "PASS: squashfs module is disabled"
 exit 0
fi

echo "FAIL: squashfs module can be loaded"
exit 1
