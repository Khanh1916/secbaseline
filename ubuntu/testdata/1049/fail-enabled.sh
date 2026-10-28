#!/bin/bash
# nfs-kernel-server is installed and enabled.
pkg_install nfs-kernel-server
systemctl enable nfs-server
