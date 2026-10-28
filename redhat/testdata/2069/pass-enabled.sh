#!/bin/bash
# firewalld is installed and enabled.
pkg_install firewalld
systemctl enable firewalld
