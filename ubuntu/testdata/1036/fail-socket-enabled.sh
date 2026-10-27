#!/bin/bash
# The avahi-daemon service is disabled but its socket starts it on demand.
pkg_install avahi-daemon
systemctl disable avahi-daemon.service
systemctl enable avahi-daemon.socket
