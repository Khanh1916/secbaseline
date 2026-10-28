#!/bin/bash

# /home must be a separate mount with the nodev option. When several mounts are
# stacked on /home, the last one is the one in use.
opts=$(findmnt -kn -o OPTIONS /home 2>/dev/null | tail -n 1)

if [ -z "$opts" ]; then
  echo "FAIL: /home is not a separate mount"
  exit 1
fi

echo "INFO: /home options: $opts"
case ",$opts," in
  *,nodev,*)
    echo "PASS: /home is mounted with the nodev option"
    exit 0
    ;;
esac

echo "FAIL: /home is not mounted with the nodev option"
exit 1
