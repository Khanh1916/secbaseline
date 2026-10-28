#!/bin/bash
# A pwquality.conf.d file requires 14 characters and four classes.
printf 'minlen = 14\nminclass = 4\n' >/etc/security/pwquality.conf.d/50-cis.conf
