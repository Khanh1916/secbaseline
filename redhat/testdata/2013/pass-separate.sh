#!/bin/bash
# /var/tmp is a mount of its own.
mount -t tmpfs -o nodev,nosuid,noexec tmpfs /var/tmp
