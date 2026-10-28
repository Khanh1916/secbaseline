#!/bin/bash
# auditd is installed but disabled.
pkg_install auditd
systemctl disable auditd
