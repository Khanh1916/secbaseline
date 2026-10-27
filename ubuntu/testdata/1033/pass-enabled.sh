#!/bin/bash
# ntp is installed and enabled.
pkg_install ntp
systemctl enable ntpsec 2>/dev/null || systemctl enable ntp
