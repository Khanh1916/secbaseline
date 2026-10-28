#!/bin/bash
# PASS_WARN_AGE is commented out.
sed -i 's/^PASS_WARN_AGE/# PASS_WARN_AGE/' /etc/login.defs
