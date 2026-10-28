#!/bin/bash
# The NFS server is installed but disabled.
pkg_install nfs-utils
systemctl disable nfs-server
