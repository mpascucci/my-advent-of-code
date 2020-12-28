#!/bin/bash
if [[ -z $1 ]]; then
	echo "Error: A file must be specified as first argument"
	exit 1
fi

fname=$1
declare -- slices

readarray -t file_array < $fname
slices=$( sed "s/ //g"  <<< "${file_array[@]}" )

active=1
inactive=0
slices=$( sed "s/\./0/g"  <<< "$slices" )
slices=$( sed "s/#/1/g"  <<< "$slices" )


# sizes of the mesh
declare -i sx=3
declare -i sy=3
declare -i sz=1
declare -i sxsy=$(( sx*sy ))

xyz2i () {
    local -i x y x
    x=$1; y=$2; z=$3
    echo $(( z*(sxsy) + y*sx + x ))
}

getv () {
    # Get the value of an element
    local -i x y x i
    x=$1; y=$2; z=$3
    i=$( xyz2i $x $y $z )
    echo ${slices:$i:1}
}

setv () {
    # set the value of one element in the given slices
    # usage: setv x y z value slices
    local -i x y z i
    local v=$4;
    local sl=$5;
    x=$1; y=$2; z=$3
    i=$( xyz2i $x $y $z )
    sl="${sl:0:$i}$v${sl:$((i+1))}"
    echo $sl
}

get_slice () {
    # return a slice as a string
    local -i z=$1
    local -i d
    local d=$(( sxsy ))
    echo ${slices:$((z*d)):$d}
}


print_slice () {
    # print a given string slice
    # rows and columns must be specified
    # $1 slice
    # $2 rows
    # $3 columns
    local slice=$1
    local rows=$2
    local cols=$3
    local y d
    for y in $( seq 0 $((rows-1)) ); do
        d=$((y*cols))
        echo ${slice:$d:$cols}
    done
}

print_slice_n () {
    # print a slice
    local -i z=$1
    local slice=$( get_slice $z )
    local y d
    print_slice $slice $sy $sx
}

empty_slice () {
    # return a slice full of '.'
    # $1 and $2 are the x and y dimensions
    local s=""
    local -i i sx sy
    sx=$1
    sy=$2
    for (( i=0; i<$(( sx*sy )); i++ )); do
        s+="$inactive"
    done
    echo "$s"
}

print_volume(){
    for ((i=0; i<sz; i++));do
        echo
        print_slice_n $i
    done
}

grow_slice () {
    # grow the slice by a '.' in both dimensions
    local -i i z idx
    z=$1
    local slice=$( get_slice $x )
    local empty_line=$( empty_slice 1 $((sx+2)) )
    local s="$empty_line"
    for ((i=0; i<$sy; i++)); do
        idx=$((z*sxsy+sy*i))
        s+="$inactive${slices:$idx:$sx}$inactive"
    done
    s="$s$empty_line"
    echo $s
}

grow () {
    # grow the space by two in each dimension
    # sizes of the new mesh
    local empty_slice=$( empty_slice $((sy+2)) $((sx+2)) )
    local s="$empty_slice"
    for ((i=0; i<$((sy)); i++)); do
        s+="$( grow_slice $i )"
    done
    slices="$s$empty_slice" 
    
    # update dimensions
    sx=$((sx+2))
    sy=$((sy+2))
    sz=$((sz+2))
    sxsy=$((sx*sy))
}

count_nbrs () {
    local -i i j k active inactive
    local v
    active=0; inactive=0
    x=$1; y=$2; z=$3
    for ((i=$((x-1)); i<$((x+2)); i++)); do
        for ((j=$((y-1)); j<$((y+2)); j++)); do
            for ((k=$((z-1)); k<$((z+2)); k++)); do
                #echo "($i,$j,$k)" >&2

                if [[ $((i+j+k)) = 0 ]]; then continue; fi
                if [[ $i -lt 0 ]] || [[ $j -lt 0 ]] || [[ $k -lt 0 ]];then
                    continue;
                fi
                if [[ $i -ge $sx ]] || [[ $j -ge $sy ]] || [[ $k -ge $sx ]];then
                    continue;
                fi
                v=$( getv $i $j $k )
                #echo "($i,$j,$k) : $v" >&2
                case $v in
                    1) let "active++";;
                    0) let "inactive++";;
                    *) continue
                esac
            done
        done
    done
    echo $active $inactive
}

next_state () {
    # give the next state based on the current
    # $1 current state
    # $2 n active neighmours
    # $3 n inavtive nieghbours
    local -i state=$1
    local -i actives=$2
    local -i inactives=$3

    if [[ $state = $active ]]; then
        if [[ $actives != 2 && $actives != 3 ]]; then
            state=$inactive
        fi
    else
        if [[ $actives = 3 ]]; then
            state=$active
        fi
    fi
    echo $state
}

update () {
    #updates the volume
    local -i x y z v actives inactives
    local -a actives_inactives
    local next_slices="$slices"
    for ((x=0; x<$sx; x++)); do
        printf '.' >&2
        for ((y=0; y<$sy; y++)); do
            for ((z=0; z<$sz; z++)); do
                v=$( getv $x $y $z )
                actives_inactives=($( count_nbrs $x $y $z ))
                actives=${actives_inactives[0]}
                inactives=${actives_inactives[1]}
                nv=$( next_state $v $actives $inactives )
                #echo "$v -(a:$actives i:$inactives)-> $nv" >&2
                next_slices=$( setv $x $y $z $nv $next_slices )
            done
        done
    done
    slices=$next_slices
}

echo "Slices: (${slices[@]})"
#setv 1 1 0 'M'
#echo
print_volume
#print_slice_n 0
#echo "---[$( empty_slice 2 2 )]==="
#s=$( grow_slice )
#print_slice $s 5 5

echo
grow
update
print_volume
