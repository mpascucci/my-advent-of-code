#!/bin/bash

declare -r CONST1=20201227

declare -i card_pkey=8987316
declare -i door_pkey=14681524
declare -i subj_n=7

declare -i card_loop_s=0
declare -i door_loop_s=0

# find the loop sizes
loop_s=0

declare -i card_encr_key=1
declare -i door_encr_key=1

declare -i tmp_pkey=1

while true;do
    # find the loop size
    if [[ $tmp_pkey = $card_pkey ]];then
        card_loop_s=$loop_s
        printf "card loop size: $card_loop_s\n"
    elif [[ $tmp_pkey = $door_pkey ]];then
        door_loop_s=$loop_s
        printf "doord loop size: $door_loop_s\n"
    fi

    # find the encription key
    if [[ $door_loop_s = 0 ]]; then
        card_encr_key=$(( (card_encr_key*card_pkey)%CONST1 ))
    fi
    if [[ $card_loop_s = 0 ]]; then
        door_encr_key=$(( (door_encr_key*door_pkey)%CONST1 ))
    fi

    if [[ $card_loop_s != 0 && $door_loop_s != 0 ]]; then
        break
    fi
    
    tmp_pkey=$(( (tmp_pkey*subj_n)%CONST1 ))
    printf "\033[2K\r$loop_s: $tmp_pkey ($card_loop_s,$door_loop_s)"
    let "loop_s++"

done

if [[ $card_encr_key != $door_encr_key ]]; then
    # the encription keys must be identical
    echo "Error"
    exit 1
fi

echo
echo Solution1: $card_encr_key $door_encr_key


