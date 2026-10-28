#!/bin/bash
# Only /home/data, not /home, is a mount with nodev.
mkdir -p /home/data
mount -t tmpfs -o nodev tmpfs /home/data
