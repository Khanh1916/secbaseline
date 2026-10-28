#!/bin/bash
# avahi is installed, its service and socket masked.
pkg_install avahi
systemctl mask avahi-daemon.service avahi-daemon.socket
