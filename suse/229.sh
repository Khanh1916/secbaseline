#!/bin/bash

if grep -iq "SUSE" /etc/issue; then
  echo "OS information found in banner."
  exit 1
fi

echo "OS information removed from banner."
exit 0