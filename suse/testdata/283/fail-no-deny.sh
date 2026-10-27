#!/bin/bash
# pam_tally2 without deny never locks.
sed -i '/^auth.*pam_unix.so/i auth\trequired\tpam_tally2.so onerr=fail audit silent' /etc/pam.d/common-auth
