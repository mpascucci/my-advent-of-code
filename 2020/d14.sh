#!/bin/bash

this_fname=$( basename "$0" | cut -f 1 -d '.' )
data_fname="${this_fname}_data.txt"

readarray -t instructions < $data_fname
mem=()
mask_len=36

declare -A addrs
for instr in "${instructions[@]}"; do
    #echo $instr
    if [ ${instr:0:4} = "mask" ]; then
        mask=${instr:7}
    else
        addr_val=($( sed -r "s/mem\[(.+)\]\s=\s(.+)/\1 \2/" <<< $instr))
        # keep track of the address
        addr=${addr_val[0]}
        addrs[$addr]=1

        val10=${addr_val[1]}
        #echo $addr $val10
        # DECIMAL --> BINAR
        valbin=$( bc <<< "obase=2;$val10" )
        len=${#valbin}
        out=$( sed "s/./0/g" <<< $mask )
        out="${out:0:$((mask_len-len))}$valbin"

        #echo ">>> $out"
        #echo ">>> $mask"
        for (( i=0; i<$mask_len; i++ )); do
            m=${mask:$i:1}
            if ! [[ $m = 'X' ]]; then
                out=$( sed "s/./$m/$((1+i))" <<< $out )
            fi
        done
        #echo ">>> $out $(( 2#$out ))"
        printf "\033[2K\rDO: $instr"
        mem[$addr]=$out
    fi
done

s1=0
for addr in ${!addrs[@]}; do
    # BINAR --> DECIMAL
    s1=$(( s1 + 2#${mem[$addr]} ))
done

echo "Solution1: $s1"

for ((i=0; i<$((2*3)); i++);do
    echo $( bc <<< "obase=2;$val10" )
done
