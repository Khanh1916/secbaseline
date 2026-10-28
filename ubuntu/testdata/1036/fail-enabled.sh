#!/bin/bash
# avahi-daemon is installed and enabled.
pkg_install avahi-daemon
systemctl enable avahi-daemon.service avahi-daemon.socket
