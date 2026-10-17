#!/bin/bash

output=$(modprobe -n -v udf 2>/dev/null)

if echo "$output" | grep -q "install /bin/true"; then
  echo "PASS: udf module is disabled"
  exit 0
fi

echo "FAIL: udf module can be loaded"
exit 1
