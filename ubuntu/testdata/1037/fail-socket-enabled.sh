#!/bin/bash
# The cups service is disabled but its socket starts it on demand.
pkg_install cups
systemctl disable cups.service cups.path
systemctl enable cups.socket
