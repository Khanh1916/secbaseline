#!/bin/bash
# /var/tmp is a symbolic link to /tmp.
rm -rf /var/tmp
ln -s /tmp /var/tmp
