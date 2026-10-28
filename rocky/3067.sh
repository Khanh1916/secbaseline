#!/bin/bash

# /etc/hosts.deny must deny every service to every client with an active
# "ALL: ALL" rule (spacing is free; options may follow).
FILE=/etc/hosts.deny

if [ ! -f "$FILE" ]; then
  echo "FAIL: $FILE does not exist"
  exit 1
fi

if grep -Eq '^[[:space:]]*ALL[[:space:]]*:[[:space:]]*ALL[[:space:]]*(:|$)' "$FILE"; then
  echo "PASS: $FILE denies all services to all clients (ALL: ALL)"
  exit 0
fi

echo "FAIL: $FILE has no active ALL: ALL rule"
exit 1
