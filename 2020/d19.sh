#!/bin/bash

# Load data

#!/bin/bash
if [[ -z $1 ]]; then
        echo "Error: A file must be specified as first argument"
        exit 1
else
    fname=$1
fi

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
done < $fname


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
        out="($out)"

        echo $out
    fi
}

# compile regex
#regex=$( compile_rule 0 )
#echo $regex

check_messages () {
    local regex=$1
    local -a messages=($2)
    local s=0
    for message in ${messages[*]}; do
        if [[ $message =~ ^$regex$ ]]; then
            valid=valid
            let "s++"
        else
            valid=invalid
        fi
        #echo "$message : $valid" >&2
    done
    echo $s
}

# Part 1 ==========
regex=$( compile_rule 0 )
#echo $regex
s1=$( check_messages $regex "${messages[*]}" )
echo "Solution 1: $s1"

# Part 2 ==========
## 42: 114 a | 19 b
## 31: 14 b | 10 a
r42=$( compile_rule 42 )
r31=$( compile_rule 31 )
## 8: 42 | 42 8
## 11: 42 31 | 42 11 31

## Messages are valid if the first part matches one or more times rule 42
## and the remaining part matches X times rules 42 and X times rule 31
## eg: 42 42 42 42 42 42 42 31 31 31 is valid

declare -i s2=0
for i in {0..6};do
    # the first part of the message
    regex="($r8)+"
    # add an equal number of 42 and 31 at the end
    for j in $( seq 0 $i ); do
        regex="$regex$r42"
    done
    for j in $( seq 0 $i ); do
        regex="$regex$r31"
    done
    # count the matches
    s2+=$( check_messages $regex "${messages[*]}" )
done
echo "Solution 2: $s2"
