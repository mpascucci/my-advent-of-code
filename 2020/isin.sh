#!/bin/bash
out=0
v=$1
a=($2)
for x in ${a[*]}; do
    if [[ $x = $v ]]; then
        out=1
        break
    fi
done
echo $out
