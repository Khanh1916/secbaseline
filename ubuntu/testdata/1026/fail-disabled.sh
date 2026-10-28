#!/bin/bash
# SELinux is disabled in its configuration.
pkg_install policycoreutils selinux-utils selinux-policy-default
sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
