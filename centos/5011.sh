#!/bin/bash

# /dev/shm must be a separate mount with the noexec option. When several mounts are
# stacked on /dev/shm, the last one is the one in use.
opts=$(findmnt -kn -o OPTIONS /dev/shm 2>/dev/null | tail -n 1)

if [ -z "$opts" ]; then
  echo "FAIL: /dev/shm is not a separate mount"
  exit 1
fi

echo "INFO: /dev/shm options: $opts"
case ",$opts," in
  *,noexec,*)
    echo "PASS: /dev/shm is mounted with the noexec option"
    exit 0
    ;;
esac

echo "FAIL: /dev/shm is not mounted with the noexec option"
exit 1
