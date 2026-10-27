#!/bin/bash

# /tmp must be a separate mount with the noexec option. When several mounts are
# stacked on /tmp, the last one is the one in use.
opts=$(findmnt -kn -o OPTIONS /tmp 2>/dev/null | tail -n 1)

if [ -z "$opts" ]; then
  echo "FAIL: /tmp is not a separate mount"
  exit 1
fi

echo "INFO: /tmp options: $opts"
case ",$opts," in
  *,noexec,*)
    echo "PASS: /tmp is mounted with the noexec option"
    exit 0
    ;;
esac

echo "FAIL: /tmp is not mounted with the noexec option"
exit 1
