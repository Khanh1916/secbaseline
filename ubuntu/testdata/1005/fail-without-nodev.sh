#!/bin/bash
# /tmp is mounted without nodev.
mount -t tmpfs -o nosuid,noexec tmpfs /tmp
