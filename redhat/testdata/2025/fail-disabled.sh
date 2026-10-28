#!/bin/bash
# SELinux is disabled in its configuration.
pkg_install policycoreutils selinux-policy-targeted
sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
