#!/bin/bash

if ! findmnt -l | grep /tmp | grep -q nosuid; then
  echo "/tmp partition nosuid option is not configured."
  exit 1
fi

echo "/tmp partition nosuid option is configured."
exit 0
