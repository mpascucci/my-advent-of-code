#!/bin/bash


# Load data

declare -a lines messages
declare line

count_nl=0
while read line; do
    if [[ -z $line ]]; then
        let "count_nl++"
        continue
    fi
    case $count_nl in
        0) lines+=("$line");;
        1) messages+=("$line");;
        *) echo "Input Error"; exit 1;;
    esac
done < "d19_data.txt"

# parse rules
declare -a rules rule
declare -i n i
for line in "${lines[@]}"; do
    i=${line%:*}
    rule=${line#*:[[:space:]]}
    # remove quotes
    rules[$i]=${rule//\"/}
done

compile_rule() {
    local rule=${rules[$1]}
    # trim whitespaces
    rule=${rule#[[:space:]]}
    rule=${rule%[[:space:]]}
    #echo "rule[$1]: $rule" >&2
    local out i
    if [[ $rule =~ a|b ]]; then
        # the rule is terminal
        echo "$rule"
    else
        # the rule is not terminal
        # recursion
        out=""
        for i in $rule;do
            #echo ">>> $i" >&2
            if [[ $i = '|' ]]; then
                out+='|'
            else
                out+=$(compile_rule $i)
            fi
        done
        echo "($out)"
    fi
}

# compile regex
regex=$( compile_rule 0 )
#echo $regex

s1=0
for message in ${messages[*]}; do
    if [[ $message =~ ^$regex$ ]]; then
        valid=yes
        let "s1++"
    else
        valid=no 
    fi
    echo "$message : $valid"
done

echo "Solution 1: $s1"
