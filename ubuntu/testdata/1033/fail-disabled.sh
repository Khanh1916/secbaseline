#!/bin/bash
# ntp is installed but disabled.
pkg_install ntp
systemctl disable ntpsec 2>/dev/null || systemctl disable ntp
