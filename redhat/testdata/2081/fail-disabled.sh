#!/bin/bash
# auditd is installed but disabled.
pkg_install audit
systemctl disable auditd
