#!/bin/bash
#cardinals are represented by these integers:
# N=0 E=1 S=2 W=3


this_fname=$( basename "$0" | cut -f 1 -d '.' )
data_fname="${this_fname}_data.txt"

readarray -t instrs < $data_fname
instrsN=${#instrs[@]}

move() {
    local instr=$1
    local cmd par

    cmd=${instr:0:1}
    par=${instr:1}

    case $cmd in
        N) cmd=0;;
        E) cmd=1;;
        S) cmd=2;;
        W) cmd=3;;
    esac

    if [[ $cmd == 'F' ]]; then
        cmd=$head
    fi
      
    case $cmd in
    0) # N
        y=$((y-par));;
    1) # E
        x=$((x+par));;
    2) # S
        y=$((y+par));;
    3) # W
        x=$((x-par));;
    *)
        echo "Parsing error: $cmd-$par" >&2
        exit 1;;
    esac
}

parse() {
    local instr=$1
    case $instr in
        L270|R90) # turn right once
            head=$(( (head+1)%4 ));;
        R270|L90) # turn left once
            head=$(( (head-1)%4 ));;
        R180|L180) # invert direction
            head=$(( (head+2)%4 ));;
        *) # other movements
            move $instr
    esac
    if [[ $head -lt 0 ]];
        then head=$(( head + 4 ));
    fi
}

head=1
x=0
y=0

wpx=(100,-10)

#for (( i=0; i<instrsN; i++ ));do
#    instr=${instrs[$i]}
#
#    printf "($x,$y) H:$head |--$instr--> "
#    parse $instr
#    echo "H:$head ($x,$y)"
#done

#x=$( sed "s/-//" <<< $x )
#y=$( sed "s/-//" <<< $y )
#echo "Solution 1 = $(( x+y ))"

# =============== Part2

declare -i sx sy wpx wpy

parse2 () {
    local instr=$1
    local -i x=$wpx
    local -i y=$wpy
    case $instr in
        N*) # move north
            wpy=$(( wpy + ${instr#N} ));;
        S*) # move north
            wpy=$(( wpy - ${instr#S} ));;
        E*) # move north
            wpx=$(( wpx + ${instr#E} ));;
        W*) # move north
            wpx=$(( wpx - ${instr#W} ));;
        L270|R90) # turn right once
            wpx=$y; wpy=-$x;;   
        R270|L90) # turn left once
            wpx=-$y; wpy=$x;;   
        R180|L180) # invert direction
            wpx=-$x; wpy=-$y;;
        F*) # move the sheep to the waypoint
            local -i n=${instr#F}
            sx=$(( sx + x*n ))
            sy=$(( sy + y*n ));;
        *) # other movements
            echo "Wrong instruction: $instr"
     esac
}

readarray -t instrs < d12_data.txt

sx=0
sy=0
wpx=10
wpy=1
for (( i=0; i<${#instrs[@]}; i++ ));do
    instr=${instrs[$i]}
    printf "($sx,$sy) wp:($wpx,$wpy) |--$instr--> "
    parse2 $instr
    echo "($sx,$sy) wp:($wpx,$wpy)"
done

sx=$( sed "s/-//" <<< $sx )
sy=$( sed "s/-//" <<< $sy )
echo "Solution 2 = $(( sx+sy ))"

