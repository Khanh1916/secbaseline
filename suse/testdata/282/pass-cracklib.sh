#!/bin/bash
# pam_cracklib requires 14 characters and one of each class.
sed -i 's/pam_cracklib.so.*/pam_cracklib.so retry=3 minlen=14 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1/' /etc/pam.d/common-password
