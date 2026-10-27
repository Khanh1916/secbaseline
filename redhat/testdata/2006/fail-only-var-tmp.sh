#!/bin/bash
# /tmp lacks nosuid; only /var/tmp, a different mount, has it.
mount -t tmpfs -o nodev,noexec tmpfs /tmp
mount -t tmpfs -o nodev,nosuid,noexec tmpfs /var/tmp
