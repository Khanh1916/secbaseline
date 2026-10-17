#!/bin/bash

if ! findmnt /tmp &> /dev/null; then
 echo "/tmp partition is not configured."
 exit 1
fi

echo "/tmp partition is configured."
exit 0
