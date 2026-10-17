#!/bin/bash

output=$(modprobe -n -v cramfs 2>/dev/null)

if echo "$output" | grep "install /bin/true"; then
 echo "Cramfs module is disable."
 exit 0
fi

echo "Cramfs module can be loaded."
exit 1
