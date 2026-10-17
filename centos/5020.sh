#!/bin/bash

if [ "$(ulimit -c)" = "0" ]; then
  echo "Core file size limit is set to 0 (disabled)."
  exit 0
fi

echo "Core file size limit is not set to 0."
exit 1
