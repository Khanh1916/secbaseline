#!/bin/bash
if lsmod | grep -qw udf; then
	  echo "udf module is loaded."
	    exit 1
fi
if modinfo udf &> /dev/null; then
	  echo "udf module is available."
	    exit 1
fi
echo "udf module is not present."
exit 0
