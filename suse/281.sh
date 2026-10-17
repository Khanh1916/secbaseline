#!/bin/bash

grep pam_tally2 /etc/pam.d/common-auth &>/dev/null

if [ $? -eq 0 ]; then
  echo "pam_tally2 is configured."
  exit 0
else
  echo "pam_tally2 is not found."
  exit 1
fi