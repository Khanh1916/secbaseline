#!/bin/bash
# pam_pwquality requires four classes but only 8 characters.
pkg_install pam_pwquality
sed -i 's/pam_cracklib.so.*/pam_pwquality.so retry=3/' /etc/pam.d/common-password
echo 'minlen = 8' >>/etc/security/pwquality.conf
echo 'minclass = 4' >>/etc/security/pwquality.conf
