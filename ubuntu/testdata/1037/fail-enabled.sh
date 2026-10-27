#!/bin/bash
# cups is installed and enabled.
pkg_install cups
systemctl enable cups.service cups.socket
