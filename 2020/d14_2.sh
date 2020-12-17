#!/bin/bash

data_fname="d14_data.txt"

readarray -t instructions < $data_fname
mem=()
mask_len=36

bin2dec () {
    echo $(( 2#$1 ))
}

dec2bin() {
    m=$( bc <<< "obase=2;$1" )
    if [[ -n ${2+x} ]]; then
        # if $2 is defined
        m=$( printf "%0${2}s" $m )
        m=$( tr ' ' '0' <<< $m )
    fi
    echo $m
}

declare -A addrs
for instr in "${instructions[@]}"; do
    printf "\033[2K\rDO: $instr"
    #echo $instr
    if [ ${instr:0:4} = "mask" ]; then
        mask=${instr:7}
    else
        addr_val=($( sed -r "s/mem\[(.+)\]\s=\s(.+)/\1 \2/" <<< $instr))
        
        # MEMORY ADDRESS
        addr=$( dec2bin ${addr_val[0]} $mask_len )

        # PREPARE DATA TO WRITE
        val10=${addr_val[1]}
        # DECIMAL --> BINAR
        data=$( dec2bin $val10 8 )

        # count occurrencies of X in mask
        xn=$( grep -o "X" <<< $mask | wc -l )
        #echo $mask $xn

        # partially apply the mask to to address
        # leave Xs
        masked_addr=""
        for (( j=0; j<$mask_len; j++ ));do
            case ${mask:j:1} in
                0)masked_addr+=${addr:j:1};;
                1)masked_addr+='1';;
                X)masked_addr+='X';;
            esac
        done

        printf " [addresses: $(( 2**$xn ))]"
     
        for ((i=0; i<$((2**xn)); i++));do
            addr=$masked_addr
            # all possible combinations of 0 and 1
            comb=$( dec2bin $i $xn)

            # change the X in the masked address with
            # this combination
            for (( j=0; j<${#comb}; j++ ));do
                v=${comb:j:1}
                addr=$( sed "s/X/$v/" <<< $addr )
            done
                      
            addr=$( bin2dec $addr )
            
            #keep track of the address
            addrs[$addr]=1

            #set the data into memory
            mem[$addr]=$data

        done
    fi
done

s2=0
for addr in ${!addrs[@]}; do
    # BINAR --> DECIMAL
    s2=$(( s2 + 2#${mem[$addr]} ))
done

echo "Solution2: $s2"


