#!/bin/bash

if [[ -z $1 ]]; then
        echo "Error: first argument required (e.g. 123456789)"
        exit 1
fi

cups=$1

declare -i current destination current_i
declare -- hand
declare -i len=${#cups}

get_cups () {
    # get $1 consecutive cups starting at position $2
    local -i p=$(( $2 % len ))
    local -i n=$1
    local -i i c
    local -- s new_cups
   
    s=""
    for (( i=0; i<$n; i++ )); do
        c=$(( (p+i) % (len) ))
        s+="${cups:$c:1}"
        #echo $i $s >&2
    done
    
    echo $s
}

cup_index () {
    # get the index of cap labeled $1
    local cups_before=${cups%$1*}
    echo ${#cups_before}
}

# the current cup is the cup -1
current=${cups:8:1}
declare -i n_cycles=10
for (( j=1; j<=100; j++ ));do
    echo "-- move $j --"
    echo "cups: $cups"
    
    # the new current cup is the one next to che current cup (modulo 10)
    current_i=$( cup_index $current )
    current_i=$(( ++current_i % (len) ))
    current=${cups:$current_i:1}
    echo "current cup: $current"

    ### remove the hand from the cups
    # the three cups after the current cup are the hand (modulo 10)
    # (the remaining cups are 7)
    hand=$( get_cups 3 $(( current_i+1 )) )
    remaining=$( get_cups 6 $(( current_i+4 )) )

    echo "hand: $hand - remaining: $remaining"

    ### find the destination cup
    # the destination cup is current cup-1 (modulo 10)
    destination=$(( (current-1) % len ))
    if [[ $destination = 0 ]];then
        destination=$((len))
    fi

    #echo "temp destination: $destination"
   
    # while destination in the hand
    # decrease destination by 1 (modulo 10)
    while [[ $hand =~ $destination ]];do
        let "--destination % len"
        #echo "Reducing destination: $destination" 
        if [[ $destination = 0 ]];then
            destination=$((len))
        fi
    done

    echo "destination: $destination"


    ### place the hand after the destination cup
    # (the cups are 10)
    cups=${remaining%$destination*}$destination$hand${remaining#*$destination}
    
    echo
done

echo "-- final --"
echo "cups: $cups"
one_i=$( cup_index 1 )
s1=$( get_cups 9 $one_i )
echo "Solution 1: ${s1:1}"
