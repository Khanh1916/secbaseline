#!/bin/bash
# Postfix is configured to listen on all interfaces.
pkg_install postfix
postconf -e inet_interfaces=all
