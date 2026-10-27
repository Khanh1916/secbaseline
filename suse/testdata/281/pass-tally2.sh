#!/bin/bash
# pam_tally2 is in common-auth.
sed -i '/^auth.*pam_unix.so/i auth\trequired\tpam_tally2.so onerr=fail audit silent deny=5 unlock_time=900' /etc/pam.d/common-auth
