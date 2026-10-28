#!/bin/bash
# avahi is installed, its service and socket disabled.
pkg_install avahi
systemctl disable avahi-daemon.service avahi-daemon.socket
