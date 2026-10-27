#!/bin/bash
# pam_tally2 is commented out.
sed -i '/^auth.*pam_unix.so/i # auth\trequired\tpam_tally2.so deny=5' /etc/pam.d/common-auth
