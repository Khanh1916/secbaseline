#!/bin/bash
# Postfix is configured to listen on all interfaces.
echo 'postfix postfix/main_mailer_type select Internet Site' | debconf-set-selections
echo 'postfix postfix/mailname string host.example.com' | debconf-set-selections
pkg_install postfix
postconf -e inet_interfaces=all
