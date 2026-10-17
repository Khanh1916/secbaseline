#!/bin/bash

output=$(modprobe -n -v squashfs 2>/dev/null)

if echo "$output" | grep "install /bin/true"; then
 echo "Squashfs module is disable."
 exit 0
fi

echo "Squashfs module can be loaded."
exit 1
