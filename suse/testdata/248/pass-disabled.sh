#!/bin/bash
# The NFS server is installed but disabled.
pkg_install nfs-kernel-server
systemctl disable nfs-server
