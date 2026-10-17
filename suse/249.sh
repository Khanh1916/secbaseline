#!/bin/bash

if rpm -q ypbind &> /dev/null; then
  echo "NIS Client is available."
  exit 1
fi

echo "NIS Client is removed."
exit 0
