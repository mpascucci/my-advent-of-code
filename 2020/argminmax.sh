#!/bin/bash
# return armin argmax min max of array-like string $1


a=($1)
argmin=0
argmax=0
the_min=${a[0]}
the_max=${a[0]}

for (( i=1; i<${#a[@]}; i++ )) do
    x=${a[$i]}
    if [[ $x -lt $the_min ]];then
        argmin=$i
        the_min=$x
    elif [[ $x -gt $the_max ]];then
        argmax=$i
        the_max=$x
    fi
done

echo "$argmin $argmax $the_min $the_max"
