#!/bin/bash
# remember=5 in pwquality.conf, which no module reads.
echo 'remember = 5' >>/etc/security/pwquality.conf
