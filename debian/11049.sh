#!/bin/bash

if dpkg -s nfs-kernel-server 2>/dev/null | grep -q "Status: install ok installed"; then
 echo "FAIL: NFS is available"
 exit 1
fi

if dpkg -s rpcbind 2>/dev/null | grep -q "Status: install ok installed"; then
 echo "FAIL: RPC is available"
 exit 1
fi

echo "PASS: NFS and RPC are disabled"
exit 0
