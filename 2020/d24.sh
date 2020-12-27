#!/bin/bash

if [[ -z $1 ]]; then
        echo "Error: first argument required (data file name)"
        exit 1
fi

parse_line() {
    # parse a line of the input data
    # separate the single movements with spaces
    local out
    out=$(sed -r 's/([ew])/\1 /g' <<< $1)
    echo $out
}

move () {
    # apply the movement $1 to the global x,y coordinates
    local instr=$1
    case $instr in
        e) let "x=x+1"; let "y=y+1" ;;
        w) let "x=x-1"; let "y=y-1" ;;
        ne) let "y=y+1" ;;
        nw) let "x=x-1" ;;
        se) let "x=x+1" ;;
        sw) let "y=y-1" ;;
        *) echo "error"; exit 1 ;;
    esac
}

declare -i x y
declare blacks

while read line; do

    printf '.'
    # ignore empty lines
    if [[ -z $line ]];then continue; fi
    
    # reset coordinates
    x=0
    y=0
    
    # parse the line
    instrs=($( parse_line $line ))

    # move according to the instructions
    for instr in ${instrs[@]}; do
        move $instr
    done

    # create a string woth the new coordinates
    s=" $x,$y "

    if [[ $blacks =~ $s ]]; then
        # target tile already black
        # remove it
        blacks=${blacks/$s/}
    else
        # target tile not yet black
        # add it
        blacks="$blacks$s"
    fi

done < $1

declare -a blakcs_v
blacks_v=($blacks)
echo
echo "Solution 1: ${#blacks_v[@]}"
