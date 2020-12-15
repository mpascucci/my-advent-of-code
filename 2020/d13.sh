#!/bin/bash

# The difference between [@] and [*]-expanded arrays in double-quotes is that "${myarray[@]}" leads to each element of the array being treated as a separate shell-word, while "${myarray[*]}" results in a single shell-word with all of the elements of the array separated by spaces (or whatever the first character of IFS is)


this_fname=$( basename "$0" | cut -f 1 -d '.' )
data_fname="${this_fname}_data.txt"

# data read
readarray -t data < $data_fname

dep=${data[0]}
IFS=',' read -a buses_x <<< ${data[1]}; unset IFS

echo "=== PART 1 ==="
# copy buses without x
buses=()
for bus in "${buses_x[@]}"; do
    if [ $bus != 'x' ]; then
        buses+=("$bus")
    fi
done
echo "Buses: ${buses[*]}"

minmaxbus=($( ./minmax.sh "${buses[*]}" ))
old_wt=${minmaxbus[1]}
echo "Max waiting time $old_wt"

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

echo
echo "=== PART 2 ==="

# data read

#IFS=',' read -a schedule <<< "2,x,3,5,7"; unset IFS
#IFS=',' read -a schedule <<< "7,13,x,x,59,x,31,19"; unset IFS
IFS=',' read -a schedule <<< "17,x,x,x,x,x,x,x,x,x,x,37,x,x,x,x,x,571,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,13,x,x,x,x,23,x,x,x,x,x,29,x,401,x,x,x,x,x,x,x,x,x,41,x,x,x,x,x,x,x,x,19"; unset IFS

sched_len=${#schedule[@]}

declare -a delays

for ((i=0; i<$sched_len; i++)); do
    v=${schedule[$i]}
    if [[ $v = 'x' ]]; then
        continue
    fi
    delays[$v]=$(((20*v-i)%v))
done

unset buses
unset buses_len
buses=(${!delays[@]})
delays=(${delays[@]})
buses_len=${#buses[@]}

echo "$buses_len Buses: ${buses[*]}"
echo "Delays: ${delays[*]}"


echo
found=0
i=1

# https://en.wikipedia.org/wiki/Chinese_remainder_theorem#Search_by_sieving
x=${delays[-1]}
b=${buses[-1]}

for j in $( seq $((buses_len-1)) -1 1 ); do
    #break
    d=${delays[$j]}
    k=0
    while true;do
        ts=$(( (x+k*b) % buses[j-1] ))
        echo "$x + $((k*$b)) -->  $ts"
        
        if [[ $ts = ${delays[$((j-1))]} ]]; then
            x=$(( x+k*b ))
            b=$(( b*buses[j-1]))
            break
        fi
        k=$((k+1))
    done

    echo $x
done

echo "Found!"
echo "Solution2: $((x))"
