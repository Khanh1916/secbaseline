#!/bin/bash
# PASS_MAX_DAYS is commented out.
sed -i 's/^PASS_MAX_DAYS/# PASS_MAX_DAYS/' /etc/login.defs
