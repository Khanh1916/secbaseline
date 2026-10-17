#!/bin/bash

if sysctl kernel.randomize_va_space 2>/dev/null | grep -q "kernel.randomize_va_space = 2"; then
  echo "kernel.randomize_va_space is set to 2 (ASLR fully enabled)."
  exit 0
fi

echo "kernel.randomize_va_space is not set to 2."
exit 1
