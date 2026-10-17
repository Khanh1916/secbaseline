#!/bin/bash
if lsmod | grep -qw squashfs; then
	  echo "squashfs module is loaded."
	    exit 1
fi

if modinfo squashfs &> /dev/null; then
	  echo "squashfs module is available."
	    exit 1
fi

echo "squashfs module is not present."
exit 0
