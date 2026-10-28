#!/bin/bash
# Postfix as shipped listens on localhost only.
pkg_install postfix
postconf -e inet_interfaces=localhost
