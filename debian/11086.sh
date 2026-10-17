#!/bin/bash

if grep "^PASS_" /etc/login.defs 2>/dev/null | grep -E "^PASS_(MAX_DAYS|MIN_DAYS|WARN_AGE)" &>/dev/null; then
 if grep "^PASS_MAX_DAYS" /etc/login.defs &>/dev/null && \ grep "^PASS_MIN_DAYS" /etc/login.defs &>/dev/null && \ grep "^PASS_WARN_AGE" /etc/login.defs &>/dev/null; then
  echo "File /etc/login.defs include PASS_MAX_DAYS, PASS_MIN_DAYS, PASS_WARN_AGE with appropiate argument."
  exit 0
 fi
fi

echo "File /etc/login.defs does not include PASS_MAX_DAYS, PASS_MIN_DAYS, PASS_WARN_AGE."
exit 1
