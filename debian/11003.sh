#!/bin/bash
if lsmod | grep -qw udf; then
	  echo "FAIL: udf module is loaded"
	    exit 1
fi
if modinfo udf &> /dev/null; then
	  echo "FAIL: udf module is available"
	    exit 1
fi
echo "PASS: udf module is not present"
exit 0
