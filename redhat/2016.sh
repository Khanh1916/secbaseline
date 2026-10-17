#!/bin/bash

if ! findmnt /home &> /dev/null; then
  echo "/home partition is not configured."
  exit 1
fi

echo "/home partition is configured."
exit 0
