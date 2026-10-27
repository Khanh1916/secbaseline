#!/bin/bash
# pwquality requires 14 characters and one of each class through credits on the PAM line.
pkg_install libpam-pwquality
sed -i 's/pam_pwquality.so.*/pam_pwquality.so retry=3 minlen=14 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1/' /etc/pam.d/common-password
