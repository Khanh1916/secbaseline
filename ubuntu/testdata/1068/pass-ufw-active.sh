#!/bin/bash
# ufw is installed, enabled and active.
pkg_install ufw iptables
ufw --force enable >/dev/null
