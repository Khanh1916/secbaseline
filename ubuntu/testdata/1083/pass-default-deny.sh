#!/bin/bash
# pam_faillock with its default of 3.
cat >/etc/pam.d/common-auth <<'EOF'
auth required pam_faillock.so preauth silent
auth [success=1 default=ignore] pam_unix.so nullok
auth [default=die] pam_faillock.so authfail
auth sufficient pam_faillock.so authsucc
auth requisite pam_deny.so
auth required pam_permit.so
EOF
