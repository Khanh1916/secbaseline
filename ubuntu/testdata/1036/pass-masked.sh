#!/bin/bash
# avahi-daemon is installed, its service and socket masked.
pkg_install avahi-daemon
systemctl mask avahi-daemon.service avahi-daemon.socket
