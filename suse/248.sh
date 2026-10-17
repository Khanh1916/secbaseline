#!/bin/bash

output=$(systemctl is-enabled nfsserver 2>/dev/null)

if [ "$output" = "disabled" ] || [ "$output" = "not-found" ]; then
  echo "PASS: NFS and RPC are disabled"
  exit 0
else
  echo "FAIL: NFS and RPC are enabled"
  exit 1
fi