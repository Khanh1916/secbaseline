#!/bin/bash
# Postfix is configured for loopback only.
echo 'postfix postfix/main_mailer_type select Local only' | debconf-set-selections
echo 'postfix postfix/mailname string host.example.com' | debconf-set-selections
pkg_install postfix
postconf -e inet_interfaces=loopback-only
