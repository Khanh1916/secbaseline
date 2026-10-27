#!/bin/bash
# chrony is installed but disabled.
pkg_install chrony
systemctl disable chrony
