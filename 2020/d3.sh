#!/bin/bash
this_fname=$( basename "$0" | cut -f 1 -d '.' )
data_fname="${this_fname}_data.txt"

# USE sed to transform the line syntax according to regex

readarray -t data < $data_fname
rows=${#data[@]}
cols=${#data[0]}

# data dimensions
# echo $rows x $cols

#shell colors
RED='\033[0;32m'
NC='\033[0m' # No Color

count_trees() {
    local step_down=$1
    local step_right=$2
    local verbose=$3
    local upto=0
    trees=0
    if [ -z "$4" ];then
        upto=$((rows-1))
    else
        upto=$(($4 < $rows-1 ? $4 : $rows-1))
    fi
    local step=0
    local col=0
    for step in $( seq 0 $upto ) ; do
        line=${data[$step]}
        if [ $((step%step_down)) != 0 ]; then
            if [[ $verbose = 1 ]]; then
                 echo -e "$step \t $line"
            fi
            continue
        fi
        row=$step
        col=$(( (step/step_down*step_right)%$cols )) 
        val=${line:$col:1}
        if [[ $verbose = 1 ]]; then
            echo -e "$step,$col \t ${line:0:$col}$RED$val$NC${line:$col+1}"
        fi
        if [[ $val == '#' ]]; then
            trees=$((trees+1))
        fi
    done
}

d=2
r=1
count_trees $d $r 1 33 
echo "($d-down, $r-right) enconutered $trees trees."

echo

count_trees 1 3 0
sol1=$trees
echo "solution 1: $sol1 trees."

count_trees 1 1 0
sol2=$((sol1*trees))
count_trees 1 5 0
sol2=$((sol2*trees))
count_trees 1 7 0
sol2=$((sol2*trees))
count_trees 2 1 0
sol2=$((sol2*trees))

echo "solution 2 is: $sol2"

