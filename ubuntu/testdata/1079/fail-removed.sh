#!/bin/bash
# auditd was removed; its configuration files remain.
pkg_install auditd audispd-plugins
pkg_remove auditd audispd-plugins
