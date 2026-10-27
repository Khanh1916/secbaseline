#!/bin/bash
# A world-writable directory without the sticky bit.
mkdir -p /srv/share
chmod 0777 /srv/share
