#!/bin/bash

# Rename 1001.sh -> 11001.sh ... 1090.sh -> 11090.sh
for i in {1001..1090}; do
    if [ -f "${i}.sh" ]; then
        new="1${i}.sh"
        mv "${i}.sh" "${new}"
        echo "INFO: Renamed ${i}.sh -> ${new}"
    else
        echo "INFO: File ${i}.sh not found, skipping"
    fi
done
