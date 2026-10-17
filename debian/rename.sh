#!/bin/bash

# Đổi tên file từ 1001.sh -> 11001.sh, ... đến 1090.sh -> 11090.sh
for i in {1001..1090}; do
    if [ -f "${i}.sh" ]; then
        new="1${i}.sh"
        mv "${i}.sh" "${new}"
        echo "Renamed ${i}.sh -> ${new}"
    else
        echo "File ${i}.sh not found, skipping..."
    fi
done
