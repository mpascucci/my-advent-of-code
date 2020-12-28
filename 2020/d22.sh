#!/bin/bash

if [[ -z $1 ]]; then
        echo "Error: A file must be specified as first argument"
        exit 1
fi

fname=$1
declare -a deck1 deck2

#read the data
declare -i player_n=0
while read line; do
    if [[ -z $line ]]; then
        continue
    fi
    if [[ $line =~ ^Player.*$ ]]; then
        let "player_n++"
        continue
    fi
    case $player_n in
        1) deck1+=("$line");;
        2) deck2+=("$line");;
    esac
done < $fname 

echo "d1: ${deck1[@]}"
echo "d2: ${deck2[@]}"
echo "================"
declare -i c1 c2

# untill one of the decks is empty
while [[ ${#deck1[@]} != 0 && ${#deck2[@]} != 0 ]]; do
    # compare the first cards
    c1=${deck1[0]}
    c2=${deck2[0]}

    # remove the first card
    deck1=(${deck1[@]:1})
    deck2=(${deck2[@]:1})

    # put the cards (higher first) at the end
    # of the winner deck
    if [[ $c1 -gt $c2 ]]; then
        deck1+=("$c1 $c2")
    else
        deck2+=("$c2 $c1")
    fi
done

score () {
    local deck=($1)
    local -i n=${#deck[@]}
    local -i s=0
    for i in $( seq 0 $n ); do
       s=$(( s + deck[i]*(n-i) )) 
    done
    echo $s
}

if [[ ${#deck1[@]} -gt 0 ]]; then
    echo "Player 1 won. Score $(score "${deck1[*]}" )"
    #echo ${deck1[*]}
else
    echo "Player 2 won. Score $(score "${deck2[*]}" )"
    #echo ${deck2[*]}
fi


