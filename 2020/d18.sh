#!/bin/bash

set -f # unset glob for '*' sign

solve_simple () {
    # Solve an expression without parenthesis
    local -i mem
    local op d
    local exp=$1
    for d in $exp;do
        #echo "-$d-" >&2 
        if [[ $d =~ [[:digit:]]+ ]]; then
            if [[ -z $mem ]];then
                mem=$d
            else
                mem="$mem$op$d"
            fi
        elif [[ $d =~ [\*\+] ]];then
            op=$d
        fi
    done
    echo $mem
}



solve_simple_2 () {
    # Solve an expression without parenthesis
    # + has precedence on *
    local -i a b
    local -- o c res out
    local -a exp=($1)
    #printf "ss2: ${exp[*]} " >&2
    local -i i=1
    while [[ "${exp[*]}" =~ [\+] ]] ;do
        # echo "exp: -${exp[*]}-" >&2
        exp_len=${#exp[@]}
        for (( i=i; i<$exp_len; i=$((i+2)) )); do
            o="${exp[$((i))]}"
            #echo "i:$i ($o) ==============" >&2
            if [[ $o = "+" ]] ;then
                a="${exp[$((i-1))]}"
                b="${exp[$((i+1))]}"
                res="$((a $o b))" # firs evaluate $o then the whole expression

                # build new expression
                out=""                             
                out+="${exp[@]:0:$((i-1))} $res ${exp[@]:$((i+2))}"
                #echo "[$out]" >&2
                exp=($out)
                break
            fi
        done
        if [[ ${#exp[*]} -gt 10 ]]; then break; fi
    done
    #printf ">>> ${exp[*]}\n" >&2
    echo $( solve_simple "${exp[*]}" )
}

#solve_simple_2 "8 * 3 + 9 + 3 * 4 * 3"

extract_next_parenthesis() {
    # extract the first occurring first level parenthesis
    # eg: in 1+(3*(2+1))+6 the result is 3*(2+1)
    local c start
    local -i open=0
    local rec=0
    local exp=$1  
    local -- memory
    for (( i=0; i<${#exp}; i++ )) {
        c=${exp:$i:1}

        case $c in
            '(')
                let "open++"
                if [[ $rec -gt 0 ]]; then
                    # if not the first open parenthesis keep it
                    memory="$memory("
                else
                    # start recordigng and store the position
                    rec=1;
                    start=$i
                fi
                ;;
            ')')
                let "open--"
                if [[ $open = 0 ]]; then
                    # return the memory
                    echo "$start $i $memory"
                    memory=""
                    rec=0
                    exit 0
                fi
                if [[ $rec -gt 0 ]]; then
                     # if not the last open parenthesis keep it
                    memory="$memory)"
                fi

                ;;
            *) 
                if [[ $rec = 1 ]]; then
                    # add to memory
                    memory="$memory$c"
                fi;;
        esac
        #echo "- $c $open $rec $memory"
    }
}

solve () {
    local -i start end res
    local -- subexp
    local exp="$1"
    while true ;do
        out=($( extract_next_parenthesis "$exp" ))
        start=${out[0]}
        end=${out[1]}
        subexp="${out[@]:2}"
        #echo "$expression" >&2
        #echo $start $end $exp >&2
        if [[ -n $subexp ]];then
            res=$( solve "$subexp" )
            exp="${exp:0:start}$res${exp:$((end+1))}"
            #printf "\r$exp" >&2
        else
            #echo ">>> $exp <<<" >&2
            echo $( solve_simple_2 "$exp" )
            break
        fi
    done
}


#solve "1 + (2 * 3) + (4 * (5 + 6))"
#solve "2 * 3 + (4 * 5)"
#solve "5 + (8 * 3 + 9 + 3 * 4 * 3)"
#solve "5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))"
#solve "((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2"

# change function for solution 1 or 2
# solution1 : solve_simple
# solution2 : solve_simple_2

readarray -t expressions < d18_data.txt
declare sol=0
\rm -f "solultiond18.csv"
for expression in "${expressions[@]}";do
    this_solution=$( solve "$expression" )
    printf "\r\033[2K$this_solution"
    sol=$((sol+this_solution))
    #echo $this_solution >> "solultiond18.csv"
done
echo
echo "Solution: $sol"

