#!/bin/bash
# The NFS server is installed and enabled.
pkg_install nfs-utils
systemctl enable nfs-server
