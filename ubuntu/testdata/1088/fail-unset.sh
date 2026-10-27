#!/bin/bash
# PASS_MIN_DAYS is commented out.
sed -i 's/^PASS_MIN_DAYS/# PASS_MIN_DAYS/' /etc/login.defs
