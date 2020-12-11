#!/bin/bash
this_fname=$( basename "$0" | cut -f 1 -d '.' )
data_fname="${this_fname}_data.txt"

echo "Loading data..."
readarray -t instructions < $data_fname
prog_len=${#instructions[*]} 

isin () {
    local a v x out
    out=0
    v=$1
    a=($2)
    for x in ${a[*]}; do
        if [[ $x = $v ]]; then
            out=1
            break
        fi
    done
    echo $out
}

execute () {
    local cmd=$1
    local par=$2
    #echo "[echo] $cmd $par"
    case $cmd in
    nop)
        next=$(( next + 1 ));;
    jmp)
        next=$(( next + par ));;
    acc)
        acc=$(( acc + par ))
        next=$(( next + 1 ));;
    *)
        echo "ERROR: $cmd Unknown command" >&2
        exit 1
    esac

}
    
run () {
    visited=""
    next=0
    acc=0
    local subs_i=$1
    local instruction visited cmd par instrarray
    echo
    echo "Starting new run (subst line:$subs_i/$prog_len)"
    while [[ $( isin $next "$visited" ) = 0 ]] && [[ $next -lt $prog_len ]] ; do
        visited="$visited $next"
        instruction="${instructions[$next]}"
        instrarray=($instruction)
        cmd=${instrarray[0]}
        if [[ $next = $subs_i ]]; then
            # exchange one command
            case $cmd in
                jmp) cmd='nop';;
                nop) cmd='jmp';;
                *) cmd=$cmd;;
            esac
        fi
        par=${instrarray[1]}
        printf "\r\033[Kacc:$acc \t next:$next ($instruction)"
        execute $cmd $par
    done

    echo
    echo "Final value of accumulator: $acc"
    if [[ $next = $prog_len ]]; then
        echo "Program terminated normally"
        correct_subst=$subs_i
    elif [[ $next -gt $prog_len ]]; then
        echo "ERROR: overflow"
    else
        echo "Infinite loop detected"
    fi
}

# calculate solution 1
run -1
s1=$acc

# calculate solution 2
correct_subst=-1
for i in $( seq 0 $prog_len ); do
    if [[ ${instructions[i]} =~ ^jmp|nop ]]; then
        run $i
    fi
    if [[ $correct_subst -ge 0 ]]; then
        break
    fi
done
s2=$acc

echo
echo "Solution 1: $s1"
echo "Solution 2: $s2"

