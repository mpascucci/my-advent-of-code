#!/bin/bash
a=($1)
the_min=${a[0]}
the_max=${a[0]}

for x in ${a[@]:1};do
    if [[ x -lt $the_min ]];then
        the_min=$x
    fi
    if [[ x -gt $the_max ]];then
        the_max=$x
    fi
done

echo "$the_min $the_max"
