#!/bin/bash
if lsmod | grep -qw cramfs; then
	  echo "FAIL: cramfs module is loaded"
	    exit 1
fi

if modinfo cramfs &> /dev/null; then
	  echo "FAIL: cramfs module is available"
	    exit 1
fi

echo "PASS: cramfs module is not present"
exit 0
