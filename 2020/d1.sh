#!/bin/bash
this_fname=$( basename "$0" | cut -f 1 -d '.' )
data_fname="${this_fname}_data.txt"

## Read the data into an array
IFS='\n' readarray -t data < $data_fname

# check the sum of the data
data_len=${#data[*]}
for i in $(seq 0 $data_len); do
    x=${data[$i]}
    for j in $(seq $i $data_len); do
        y=${data[$j]}
        if [[ $((x+y)) == 2020 ]]; then
            echo "found 2 numbers that add up to 2020:"
            echo "$x+$y = 2020, $x*$y = $((x*y))"
        elif [[ $((x+y)) < 2020 ]]; then
            for k in $(seq $j $data_len); do
                z=${data[$k]}
                if [[ $((x+y+z)) == 2020 ]]; then
                    echo "found 3 numbers that add up to 2020:"
                    echo "$x+$y+$z = 2020, $x*$y*$z = $((x*y*z))"
                fi
    
            done
        fi
    done
done
