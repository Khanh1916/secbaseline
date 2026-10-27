#!/bin/bash
# rsyslog is installed and enabled.
pkg_install rsyslog
systemctl enable rsyslog
