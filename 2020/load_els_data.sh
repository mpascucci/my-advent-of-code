#!/bin/bash

# Read Empy Lines Separated data files.
# Regroup the adjacent lines on one line
# Eliminate the blank lines

if [[ $# -lt 1 ]]; then
    echo "expected file name"
    exit 1
fi

fname=$1

if [[ -n $2 ]]; then
    output_sep="$2"
else
    output_sep=""
fi

buffer=""
lines=""

while read line; do
    if [[ -z $line ]]; then
        lines="$lines\n${buffer:${#output_sep}}"
        buffer=""
    else
        buffer="$buffer$output_sep$line"
    fi
done < $fname
lines="$lines\n${buffer:${#output_sep}}"


echo -e "${lines:2}"

