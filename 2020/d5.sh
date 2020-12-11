#!/bin/bash
this_fname=$( basename "$0" | cut -f 1 -d '.' )
data_fname="${this_fname}_data.txt"


help_f () {
    local code=$1
    local n=$(( 2**${#code} ))
    local lo=0
    local hi=$(( n-1 ))
    #echo $code,$lo,$hi
    for i in $( seq 0 $(( ${#code} -1 )) ); do
        x=${code:i:1}
        if [[ $x = 1 ]]; then
            # take the upper half
            lo=$((lo + (hi+1-lo)/2))
        else
            # take the lower half
            hi=$((hi - (hi+1-lo)/2))
        fi
        #echo $lo,$hi
    done
    
    local out
    if [[ ${code: -1} == 1 ]]; then
        out=$hi
    else
        out=$lo
    fi

    echo $out

}


decode_seat () {
    local code=$1
    row=""
    col=""
    seat_id=""
    
    local row_code=${code:0:7} 
    local col_code=${code:7}

    # translate into binary
    row_code=$( tr 'F' '0' <<< $row_code )
    row_code=$( tr 'B' '1' <<< $row_code )
    col_code=$( tr 'R' '1' <<< $col_code )
    col_code=$( tr 'L' '0' <<< $col_code )

    #echo "$row_code-$col_code"
    row=$( help_f $row_code )
    col=$( help_f $col_code )

    seat_id=$(( row*8 + col ))

}

seat_ids=()
max_id=0
while read line; do
    decode_seat $line
    echo -e "ROW:$row\tCOL:$col\tID:$seat_id"
    seat_ids+=("$seat_id")
    if [[ max_id -lt $seat_id ]]; then
        max_id=$seat_id
    fi
done < $data_fname

echo

echo "max seat ID: $max_id"

seats_as_str="${seat_ids[@]}"
#echo "$seats_as_str" > seats_as_str.txt
#max_id=896

echo "Missing seat(s):"
for ((i=0; i<$max_id; i++));do
    if [[ -z $( grep "$i" <<< $seats_as_str ) ]];then
        echo $i
    fi
done
