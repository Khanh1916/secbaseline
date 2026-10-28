#!/bin/bash
# ntpd is installed and enabled.
pkg_install ntp
systemctl enable ntpd
