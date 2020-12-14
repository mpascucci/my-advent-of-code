#!/bin/bash

# The difference between [@] and [*]-expanded arrays in double-quotes is that "${myarray[@]}" leads to each element of the array being treated as a separate shell-word, while "${myarray[*]}" results in a single shell-word with all of the elements of the array separated by spaces (or whatever the first character of IFS is)


this_fname=$( basename "$0" | cut -f 1 -d '.' )
data_fname="${this_fname}_data.txt"

readarray -t data < $data_fname

dep=${data[0]}
readarray -t -d ',' buses_x <<< ${data[1]}

echo $dep
echo ${buses_x[@]}

# copy buses without x
buses=()
for bus in "${buses_x[@]}"; do
    if [ $bus != 'x' ]; then
        buses+=("$bus")
    fi
done
echo ${buses[@]}

minmaxbus=($( ./minmax.sh "${buses[*]}" ))
old_wt=${minmaxbus[1]}
my_bus=${max_wt}
echo "max waiting time $old_wt"

for bus in "${buses[@]}"; do
    if [ $bus = 'x' ]; then
        continue
    elif [ $bus = 0 ]; then
        echo 0
    else
        wt=$(( bus - dep % bus )) # waiting time
        echo $bus $wt
        if [[ $wt -lt $old_wt ]]; then
            old_wt=$wt
            my_bus=$bus
        fi
    fi
done

echo "Erliest bus: $my_bus. Waiting time: $old_wt minutes"
echo "Solution 1: $(( my_bus*old_wt ))"

