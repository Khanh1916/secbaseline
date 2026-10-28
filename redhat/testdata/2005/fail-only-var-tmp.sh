#!/bin/bash
# /tmp lacks nodev; only /var/tmp, a different mount, has it.
mount -t tmpfs -o nosuid,noexec tmpfs /tmp
mount -t tmpfs -o nodev,nosuid,noexec tmpfs /var/tmp
