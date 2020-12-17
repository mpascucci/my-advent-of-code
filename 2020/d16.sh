#!/bin/bash

if [[ -z $1 ]]; then
	echo "Error: A file must be specified as first argument"
	exit 1
fi
fname=$1

declare -A rules
declare -a tickets=()
declare my_ticket rule
declare rule_syntax=".+: ([[:digit:]]+)-([[:digit:]]+) or ([[:digit:]]+)-([[:digit:]]+)"

# PARSE DATA
declare -i count_nl="0"
while read line; do
	#echo "line: $line"
	if [[ -z $line ]]; then
		let "count_nl++"
                continue #do not process this line
	fi
		
	case $count_nl in
	0) #rules (name: 40-683 or 701-974)
	    rule_name=$( sed -r "s/(.*):.*/\1/" <<< $line )
            rule_params=($( sed -r "s/$rule_syntax/\1 \2 \3 \4/" <<< $line ))
            #echo ${rule[*]}
            rules["$rule_name"]="${rule_params[@]}"
	    ;;
        1) # my ticket
            IFS=',' read -a my_ticket <<< $line; unset IFS
            ;;
        2) # tickets
            if [[ ${line:0:1} != 'n' ]]; then
                #echo "# $line"
                IFS=',' read -a ticket <<< $line; unset IFS
                tickets+=("${ticket[*]}")
            fi
            ;;
	esac
done < $fname

echo "=== Rules ==="
printf "%s\n" "${!rules[@]}"
echo

echo "=== My ticket ==="
fields_n=${#my_ticket[@]}
echo ${my_ticket[@]}
echo "$fields_n fields"
echo

echo "=== Ticket 0 ==="
ticket0=${tickets[0]}
echo ${ticket0[@]}
echo


echo "Nearby ticktes: ${#tickets[@]}"
echo

# var 'ticket' was previously an array, here it must be a string
# if we do not unset it, the first element will be reverenced
unset ticket
#for ticket in "${tickets[@]}";do
#    echo ${ticket[*]}
#done
#echo

apply_rule() {
    # apply a rule (by name) to a number
    local rule_name=$1
    local -i n=$2
    local p0 p1 p2 p3 sat res
    read -a rule <<< ${rules[$rule_name]}
    p0=${rule[0]}
    p1=${rule[1]}
    p2=${rule[2]}
    p3=${rule[3]}
    sat=0
    if [[ $n -ge $p0 ]] && [[ $n -le $p1 ]] || [[ $n -ge $p2 ]] && [[ $n -le $p3 ]] ;then
        sat=1                
    fi
    #echo ">>> $n $rule_name $p0 $p1 $p2 $p3 --> $sat" >&2
    echo $sat
}

declare -a rule_result=()

tser=0

unset ticket
declare -a valid_tickets=()

for ticket in "${tickets[@]}";do
    valid_ticket=1
    for n in ${ticket[*]}; do
        valid_field=0
        #echo "${ticket[*]} : $n"
        for rule_name in "${!rules[@]}"; do
            res=$( apply_rule "$rule_name" $n)
            if [[ $res = 1 ]];then
                valid_field=1
                break
            fi
            #echo "$rule_name $valid"
        done
        #echo "---> $valid"
        if [[ $valid_field = 0 ]]; then
            tser=$((tser+n))
            valid_ticket=0
        fi
    done
    if [[ $valid_ticket = 1 ]]; then
        valid_tickets+=("${ticket[*]}")
    fi
done

echo "Solution1: $tser"
#printf "%s\n" "${valid_tickets[@]}" > "temp.csv"
#readarray -t valid_tickets < temp.csv

# add my ticket
valid_tickets+=("${my_ticket[*]}")

echo
echo "Valid tickets: ${#valid_tickets[@]}"
echo


declare -i i=0
declare -a fields=()
unset ticket rule_name n j valid

echo "Assigning fields..."
while [[ ${#fields[@]} -lt $fields_n ]] ;do
for rule_name in "${!rules[@]}"; do

    if [[ "${fields[*]}"  =~ $rule_name ]];then continue; fi

    # echo === $rule_name ${rules[$rule_name]} ===
    valids=0
    for (( j=0; j<${fields_n}; j++ )) ; do
        if [[ -n "${fields[$j]}" ]]; then continue; fi
        #echo "j $j"
        for ticket in "${valid_tickets[@]}";do
            ticket_array=($ticket)
            #echo ticket ${ticket}
            n=${ticket_array[$j]}
            valid=$( apply_rule "$rule_name" $n )
            if [[ $valid = 0 ]];then
                #echo "$j: $valid"
                break
            fi
        done
        if [[ $valid = 1 ]];then
            #echo "$j: $valid"
            jlast=$j
            let "valids++"
        fi
        if [[ $valids -gt 1 ]];then
            break
        fi
    done
    if [[ $valids = 1 ]];then
        printf "\r\033[2K$rule_name ---> field $jlast"
        fields[$jlast]="$rule_name"
    fi
done
done

echo "Departure fields on my ticket:"
declare -i s2=1
for ((i=0; i<$fields_n; i++)); do
    #field in "${fields[@]}";do
    field=${fields[$i]}
    if [[ $field =~ ^departure ]]; then
        v=${my_ticket[$i]}
        echo "$i: $field: $v"
        echo "$i: $field: $v"
        let "s2=s2*v"
    fi
done

echo
echo "Solution2: $s2"

