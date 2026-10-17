#!/bin/bash

if find / -type d -perm -0002 -a ! -perm -1000 2>/dev/null | grep -q .; then
  echo "World-writable directories without sticky bit found."
  exit 1
fi

echo "All world-writable directories have sticky bit set."
exit 0
