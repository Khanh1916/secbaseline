#!/bin/bash
# pam_tally2 locks only after 10 failures.
sed -i '/^auth.*pam_unix.so/i auth\trequired\tpam_tally2.so onerr=fail audit silent deny=10' /etc/pam.d/common-auth
