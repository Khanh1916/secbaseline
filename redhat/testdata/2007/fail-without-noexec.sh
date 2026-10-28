#!/bin/bash
# /tmp is mounted without noexec.
mount -t tmpfs -o nodev,nosuid tmpfs /tmp
