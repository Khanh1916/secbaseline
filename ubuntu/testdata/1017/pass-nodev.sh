#!/bin/bash
# /home is mounted with nodev.
mount -t tmpfs -o nodev,nosuid tmpfs /home
