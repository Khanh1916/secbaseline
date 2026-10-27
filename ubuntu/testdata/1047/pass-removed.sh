#!/bin/bash
# The telnet server was removed; configuration files remain.
pkg_install telnetd
pkg_remove telnetd inetutils-telnetd
