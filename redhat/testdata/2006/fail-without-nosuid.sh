#!/bin/bash
# /tmp is mounted without nosuid.
mount -t tmpfs -o nodev,noexec tmpfs /tmp
