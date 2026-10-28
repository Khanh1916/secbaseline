#!/bin/bash
# pwquality requires 14 characters and four classes.
pkg_install libpam-pwquality
echo 'minlen = 14' >>/etc/security/pwquality.conf
echo 'minclass = 4' >>/etc/security/pwquality.conf
