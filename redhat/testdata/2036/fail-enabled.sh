#!/bin/bash
# avahi is installed and enabled.
pkg_install avahi
systemctl enable avahi-daemon.service avahi-daemon.socket
