#!/bin/bash
# Four classes, but only 8 characters.
pkg_install libpam-pwquality
echo 'minlen = 8' >>/etc/security/pwquality.conf
echo 'minclass = 4' >>/etc/security/pwquality.conf
