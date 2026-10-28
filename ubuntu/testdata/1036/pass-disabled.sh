#!/bin/bash
# avahi-daemon is installed, its service and socket disabled.
pkg_install avahi-daemon
systemctl disable avahi-daemon.service avahi-daemon.socket
