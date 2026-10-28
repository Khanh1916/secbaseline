#!/bin/bash
# pam_pwquality replaces pam_cracklib and requires 14 characters and four classes.
pkg_install pam_pwquality
sed -i 's/pam_cracklib.so.*/pam_pwquality.so retry=3/' /etc/pam.d/common-password
echo 'minlen = 14' >>/etc/security/pwquality.conf
echo 'minclass = 4' >>/etc/security/pwquality.conf
