#!/bin/bash
# /tmp lacks noexec; only /var/tmp, a different mount, has it.
mount -t tmpfs -o nodev,nosuid tmpfs /tmp
mount -t tmpfs -o nodev,nosuid,noexec tmpfs /var/tmp
