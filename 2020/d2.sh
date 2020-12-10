#!/bin/bash
this_fname=$( basename "$0" | cut -f 1 -d '.' )
data_fname="${this_fname}_data.txt"

# USE sed to transform the line syntax according to regex

regexp='s/^([0-9]+)-([0-9]+)\s(\w+):\s(\w+)/\1 \2 \3 \4/' 

np1=0
np1=2

while IFS= read -r line
do
    # the outer () operate word split
    out=($( sed -r "$regexp" <<< $line)) 
    min_len=${out[0]}
    max_len=${out[1]}
    c=${out[2]}
    entry=${out[3]}
    
    t=$( grep -o "$c" <<< $entry | wc -l ) 

    if [ $t -ge $min_len -a $t -le $max_len ]; then
        np1=$((np1+1))
        #echo $c, $entry, $t
    fi

    occ=0
    # does the key match the first occurrence?
    if [ $c == ${entry:min_len-1:1} ]; then
        occ=$((occ+1))
    fi
    # does it match the second?
    if [ $c == ${entry:max_len-1:1} ]; then
        occ=$((occ+1))       
    fi
    if [ $occ = 1 ]; then
        np2=$((np2+1))
        #echo $line
    fi
    
done < $data_fname

echo $np1, $np2
