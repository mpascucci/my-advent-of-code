#!/bin/bash
this_fname=$( basename "$0" | cut -f 1 -d '.' )
data_fname="${this_fname}_data.txt"



get_unique_chars_in_str() {
    local line=$1    
    local line_len=${#line}
    local i=0
    local char_set=()
    while [[ ${#line} -gt 0 ]]; do
        # cunsume the string by replacing all occurencies of the first char with ''
        char=${line:0:1}
        chars_set+=($char)
        i=$((i+1))
        line="$( sed "s/$char//g" <<< $line )"
        #echo $char $line
    done
    echo "${chars_set[*]}"
}

lines=($( ./load_els_data.sh $data_fname ))

# load data, add a comma to separate the lines
lines=($( ./load_els_data.sh $data_fname ',' ))
s1=0
s2=0
for line in ${lines[*]}; do
    #echo ">>> $line"
    # commas+1 = number of people in group
    people=$(( $( grep -o ',' <<< $line | wc -l ) + 1 ))
    str=$( sed 's/,//g' <<< $line )
    uni=$( get_unique_chars_in_str "$str")
    for c in $uni;do
        count=$( grep -o "$c" <<< $line | wc -l )
        #echo $c, $count
        if [[ $count = $people ]]; then
            s2=$(( s2 + 1 ))
        fi
    done

    uni=($uni) #convert into array
    s1=$(( s1+ ${#uni[*]} ))

done
echo "Solution 1: $s1"
echo "Solution 2: $s2"


