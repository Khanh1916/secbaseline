#!/bin/bash

if ! findmnt /var/tmp &> /dev/null; then
  echo "/var/tmp is not bind mounted to /tmp."
  exit 1
fi

echo "/var/tmp is bind mounted to /tmp."
exit 0
