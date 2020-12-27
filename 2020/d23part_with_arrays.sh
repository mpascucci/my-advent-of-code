#!/bin/bash

if [[ -z $1 ]]; then
        echo "Error: first argument required (e.g. 123456789)"
        exit 1
fi
cups_str=$1

declare -a cups hand remaining
for (( i=0; i<${#cups_str}; i++ )); do
    n=${cups_str:i:1}
    cups+=("$n")
done
 
declare -i current destination current_i
declare -i len=${#cups[@]}

get_cups () {
    # get $1 consecutive cups starting at position $2
    local -i p=$(( $2 % len ))
    local -i n=$1
    local -i i c
    local -- s new_cups
   
    s=()
    for (( i=0; i<$n; i++ )); do
        c=$(( (p+i) % (len) ))
        s+=("${cups[$c]}")
        #echo $i $c $s >&2
    done
    
    echo ${s[@]}
}


index_of () {
    # get the index of element $1 in array-string $2
    local -i i
    local -a v=($2)
    for (( i=0; i<$len; i++ )); do
        if [[ ${v[$i]} = $1 ]]; then
            echo $i
            exit 0
        fi
    done
    exit 1
}

# the current cup is the cup -1
current=${cups[8]}
declare -i n_cycles=10
for (( j=1; j<=100; j++ ));do
    echo "-- move $j --"
    #echo "cups: ${cups[@]}"
    
    # the new current cup is the one next to che current cup (modulo 10)
    current_i=$( index_of $current "${cups[*]}" )
    current_i=$(( ++current_i % (len) ))
    #echo "current_i $current_i"
    current="${cups[$current_i]}"
    #echo "current cup: $current"

    ### remove the hand from the cups
    # the three cups after the current cup are the hand (modulo 10)
    # (the remaining cups are 7)
    hand_str="$( get_cups 3 $(( current_i+1 )) )"
    hand=($hand_str)
    remaining_str="$( get_cups 6 $(( current_i+4 )) )"
    remaining=($remaining_str)
    #echo "hand: [${hand[*]}] - remaining: [${remaining[*]}]"

    ### find the destination cup
    # the destination cup is current cup-1 (modulo 10)
    destination=$(( (current-1) % len ))
    if [[ $destination = 0 ]];then
        destination=$((len))
    fi

    #echo "temp destination: $destination"

    # while destination in the hand
    # decrease destination by 1 (modulo 10)
    #echo $( ./isin.sh "${hand[*]}" $destination) 
    while [[ $( ./isin.sh "${hand[*]}" $destination ) = 1 ]];do
        let "--destination % len"
        #echo "Reducing destination: $destination"
        if [[ $destination = 0 ]];then
            destination=$((len))
        fi
    done

    #echo "destination: $destination"

    ### place the hand after the destination cup
    # (the cups are 10)
    dest_i=$( index_of $destination "${remaining[*]}" )
    #echo "destination index $dest_i"
    cups=()
    cups+=(${remaining[@]:0:$dest_i})
    cups+=($destination)
    cups+=(${hand[*]})
    cups+=(${remaining[@]:$((dest_i+1))})
    #cups=($cups_str)
    #echo "[${cups[*]}]"
done

echo "-- final --"
echo "cups: ${cups[*]}"
one_i=$( index_of 1 "${cups[*]}" )
s1=($( get_cups 9 $one_i ))
echo "Solution 1: ${s1[@]:1}"
