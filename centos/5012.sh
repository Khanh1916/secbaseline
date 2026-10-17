#!/bin/bash

if ! findmnt /var &> /dev/null; then
 echo "/var partition is not configured."
 exit 1
fi

echo "/var partition is configured."
exit 0
