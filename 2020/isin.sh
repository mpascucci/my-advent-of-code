#!/bin/bash
# return 1 if array-like string $1 contains $2
# return 0 otherwise

if [[ $# -lt 2 ]]; then
    echo "2 arguments expected"
    echo "./isin.sh \"1 2 3\" \"1\" "
fi

out=0

v=$2
a=($1)

for x in ${a[@]}; do
    if [[ $x = $v ]]; then
        out=1
        break
    fi
done
echo $out
