#!/bin/bash
# Log files are not writable by group or readable by others.
find /var/log -type f -exec chmod g-wx,o-rwx {} +
