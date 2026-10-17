#!/bin/bash

if rpm -q ypserv &> /dev/null; then
  echo "NIS server is available."
  exit 1
fi

echo "NIS server is removed."
exit 0
