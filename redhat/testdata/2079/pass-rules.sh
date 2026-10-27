#!/bin/bash
# Audit rules are configured.
pkg_install audit
echo '-w /etc/passwd -p wa -k identity' >/etc/audit/rules.d/50-cis.rules
echo '-a always,exit -F arch=b64 -S sethostname -k system-locale' >>/etc/audit/rules.d/50-cis.rules
cat /etc/audit/rules.d/*.rules >/etc/audit/audit.rules
