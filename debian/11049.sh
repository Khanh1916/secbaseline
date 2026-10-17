#!/bin/bash

if dpkg -s nfs-kernel-server 2>/dev/null | grep -q "Status: install ok installed"; then
 echo "NFS is available"
 exit 1
fi

if dpkg -s rpcbind 2>/dev/null | grep -q "Status: install ok installed"; then
 echo "RPC is available"
 exit 1
fi

echo "NFS and RPC is disable"
exit 0
