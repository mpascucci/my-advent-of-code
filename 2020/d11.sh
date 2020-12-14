#!/bin/bash
this_fname=$( basename "$0" | cut -f 1 -d '.' )
data_fname="${this_fname}_data.txt"

readarray -t lines < $data_fname
rows=${#lines[@]}
line0="${lines[0]}"
cols=${#line0}

datastr=""
for line in ${lines[@]};do
    datastr+=$line
done
echo $datastr

echo "Loaded map $rows x $cols"

min () {
    local x=$1
    local y=$2
    if [[ $x -le $y ]];then
        echo $x
    else
        echo $y
    fi
}


max () {
    local x=$1
    local y=$2
    if [[ $x -ge $y ]];then
        echo $x
    else
        echo $y
    fi
}

idx2d () {
    local row=$1
    local col=$2    
    echo $(( col + row*cols ))
}

check_around () {
    local row=$1
    local col=$2
    
    local r0 r1 c0 c1

    r0=$(( row-1 ))
    r0=$( max 0 $r0 )
    r1=$(( row+1 ))
    r1=$( min $r1 $(( $rows-1 )) )
    c0=$(( col-1 ))
    c0=$( max 0 $c0 )
    c1=$(( col+1 ))
    c1=$( min $c1 $(( $cols-1 )) )

    local r c ept occ cr cp id
    ept=0
    occ=0

    for (( r=$r0; r<=$r1; r++ )); do
        for (( c=$c0; c<=$c1; c++ )); do
            if [[ $c == $col ]] && [[ $r == $row ]]; then
                # do not count the center
                continue
            fi

            id=$( idx2d $r $c )
            cp=${datastr:$id:1}

            if [[ $cp == 'L' ]]; then
                ept=$(( ept + 1))
            elif [[ $cp == '#' ]]; then
                occ=$(( occ + 1))
            fi
        done
    done
echo $ept $occ
}

update_seat () {
    local row=$1
    local col=$2

    local id=$( idx2d $row $col )
    local old=${datastr:$id:1}
    
    local ept_occ ept occ
    # do not update empty places
    if [[ $old == "." ]]; then
        echo $old > "temp_$id"
        return 0
    else
        ept_occ=($( check_around $row $col ))
        ept=${ept_occ[0]}
        occ=${ept_occ[1]}
    fi

    local cp new
    new=$old

    if [[ $old == 'L' ]] && [[ $occ == 0 ]]; then
        new='#'        
    elif [[ $old == '#' ]] && [[ $occ -ge 4 ]]; then
        new='L' 
    fi
    
    #echo "($ept,$occ) $old-->$new" "${cr:0:$col}${new}${cr:$col+1}" >&2
    #cr=${newlines[$row]}

    echo $new > "temp_$id"

}


read_new () {
    local files fn newrow r c newlines cr
    local files=($(ls temp_*))
    local fn=${#files}
    #local s r
    #for (( r=0; r<$rows; r++ )); do
    #    newrow=""
    #    for (( c=0; c<$cols; c++ )); do
    #    newrow+='-'
    #    done
    #    newlines=("${newlines[@]}" $newrow)
    #done

    local s="$datastr"

    local f id
    for f in ${files[@]}; do
        read v < $f
        id=$(sed 's/temp_//' <<< $f)
        id=$(( id + 1 ))
        #echo $f $id $v >&2
        s=$( sed s/./$v/$id <<< $s)
    done
    echo $s
}

print_datastr () {
    local a s r
    s=$1
    for r in $( seq 0 $rows); do
        a=$(( $r*$rows ))
        printf "${s:$a:$cols}\n"
    done
}

#print_datastr $datastr
printf "Running simulation\n"
#update_seat 0 0
#datastr=$( read_new )
#print_datastr $datastr
#\rm temp_*



while [[ 1 = 1 ]]; do
    for (( r=0; r<$rows; r++ )); do
        for (( c=0; c<$cols; c++ )); do
            update_seat $r $c $datastr &
        done
    done
    printf "."
    wait
    new_datastr=($( read_new ))
    \rm temp_*

    #echo "---"
    #print_datastr $datastr
    #print_datastr $new_datastr

    if [[ $new_datastr == $datastr ]]; then break; fi
    datastr="$new_datastr"
    #break       
done
print_datastr $datastr


s1=$( grep -o "#" <<< $datastr | wc -l)
echo
echo "Solution 1: $s1"

       

 

