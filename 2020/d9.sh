#!/bin/bash
this_fname=$( basename "$0" | cut -f 1 -d '.' )
data_fname="${this_fname}_data.txt"

echo "Loading data..."
readarray -t lines < $data_fname
code_len=${#lines[*]}

pre_len=25

check_valid () {
    isvalid=0
    for x in $key;do
        if [[ $(./isin.sh $((v-x)) "$key") = 1 ]]; then
            isvalid=1
        fi
    done
}

for (( i=$pre_len; i<$code_len; i++)); do
    key="${lines[@]:i-$pre_len:$pre_len}"
    v=${lines[i]}
    isvalid=0
    check_valid
    printf "\rChecking element: $i/$code_len"
    if [[ $isvalid = 0 ]]; then
        s1=$v
        break
    fi

done

echo "Solution 1: $s1"

for (( i=0; i<$code_len; i++)); do
    s=${lines[i]}
    for (( j=i+1; j<$code_len; j++)); do
        x=${lines[j]}
        s=$((s+x))
        printf "\rfrom:$i - to:$j"
        if [[ $s -ge $s1 ]];then
            break
        fi
    done
    if [[ $s == $s1 ]];then
        break
    fi
done

echo
addends="${lines[@]:i:j-i}"
minmax=($( ./minmax.sh "$addends" ))
the_min=${minmax[0]}
the_max=${minmax[1]}
echo "min:$the_min + max:$the_max = $(( the_min+the_max ))"

