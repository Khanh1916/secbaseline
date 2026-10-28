#!/bin/bash
# cups is installed, its service, socket and path units disabled.
pkg_install cups
systemctl disable cups.service cups.socket cups.path
