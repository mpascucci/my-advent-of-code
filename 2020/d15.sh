#!/bin/bash

# readarray read lines separated by newline
# read reads one line and with -a splits at IFS
#IFS="," read -a data <<< "11,18,0,20,1,7,16" unset IFS
IFS="," read -a data <<< "0,3,6" unset IFS

data_len=${#data[@]}

# this array stores the last index of the extracted numbers
declare -a idx

# fill d with data. The first index is 1
for (( i=0; i<$data_len-1; i++ )); do
    n=${data[$i]}
    idx[$n]=$((i+1))
    printf "$((i+1)) : $n start\n"
done

# the next number is the last of data
new_n=${data[-1]}

declare -a queue=()
declare -i q_len=3
queue_append () {
    if [[ ${#queue[@]} -ge $q_len ]];then
        queue=("${queue[@]:1}")
    fi
    queue+=("$1")
}

# calculate the following numbers
spoken_at (){
    local at=$1
    for (( i=$data_len; i<=$((at-1)); i++ ));do
        #printf "\033[2K$((i*100/(at-1)))%%\t$i : $new_n" >&2

        n=${idx[$new_n]:-0} # get the index or default to 0
        idx[$new_n]=$i

        if [[ $n = 0 ]]; then
            #printf " (new)" >&2
            # new number
            new_n=0
        else
            # already spoken
            #printf " (seen at %d)" "$n" >&2
            new_n=$((i-n))
        fi
        #printf "\r" >&2

        if [[ $new_n = 0 ]]; then
            printf "\e[31m$new_n\e[0m\n" >&2
        else
            printf "$new_n\n" >&2
        fi

    done
    echo $new_n
}



s1=$( spoken_at 200 )
echo
echo "Solultion 1: $s1"
#s2=$( spoken_at 30000000 )
#echo "Solultion 1: $s2"

