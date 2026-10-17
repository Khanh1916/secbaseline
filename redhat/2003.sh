#!/bin/bash

output=$(modprobe -n -v udf 2>/dev/null)

if echo "$output" | grep -q "install /bin/true"; then
  echo "Udf module is disable."
  exit 0
fi

echo "Udf module can be loaded."
exit 1
