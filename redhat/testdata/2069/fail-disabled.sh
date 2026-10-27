#!/bin/bash
# firewalld is installed but disabled.
pkg_install firewalld
systemctl disable firewalld
