#!/bin/bash
# firewalld is installed but masked.
pkg_install firewalld
systemctl mask firewalld
