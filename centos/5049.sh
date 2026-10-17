#!/bin/bash

# Check if NFS server is disabled
if systemctl is-enabled nfs-server &> /dev/null; then
  echo "nfs-server is enabled."
  exit 1
fi

echo "nfs-server is disabled."
exit 0
