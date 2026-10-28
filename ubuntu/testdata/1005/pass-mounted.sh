#!/bin/bash
# /tmp is mounted with nodev, nosuid and noexec.
mount -t tmpfs -o nodev,nosuid,noexec tmpfs /tmp
