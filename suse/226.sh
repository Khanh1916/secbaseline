#!/bin/bash

if rpm -q setroubleshoot &> /dev/null; then
  echo "setroubleshoot is installed."
  exit 1
fi

echo "setroubleshoot is not installed."
exit 0
