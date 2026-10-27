#!/bin/bash
# /home is mounted without nodev.
mount -t tmpfs -o nosuid tmpfs /home
