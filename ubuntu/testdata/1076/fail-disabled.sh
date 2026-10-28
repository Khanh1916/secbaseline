#!/bin/bash
# rsyslog is installed but disabled.
pkg_install rsyslog
systemctl disable rsyslog
