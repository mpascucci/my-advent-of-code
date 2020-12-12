#!/bin/bash
this_fname=$( basename "$0" | cut -f 1 -d '.' )
data_fname="${this_fname}_data.txt"

readarray -t adapters < $data_fname

# set IFS because sort works on lines
IFS=$'\n'
adapters=($(sort -n <<< "${adapters[*]}"))
unset IFS

# add the outlet and the device
device=$(( adapters[-1] +3))
adapters=(0 ${adapters[@]} $device )
adapters_len=${#adapters[*]}
#echo "Ordered adapters: [${adapters[*]}]"

d0=0;d1=0;d2=0;dg=0
for ((i=0; i<$adapters_len-1; i++ )) ;do
    d=$(( adapters[i+1] - adapters[i] ))
    #echo "calc ${adapters[i+1]}-${adapters[i]} $d"
    case $d in
        1) d1=$((d1+1));;
        2) d2=$((d2+1));;
        3) d3=$((d3+1));;
        *) dg=$((dg+1));;
    esac    
done

echo "Diffs: (1)$d1, (2)$d2, (3)$d3,  (3+)$dg"
echo "Solution 1: $((d1*d3))"

echo "Ordered adapters: [${adapters[*]}]"

RED='\033[0;31m'
NC='\033[0m' # No Color
echo

# calc redundancy
r=0
rv=()
count=0
printf "Redundant (red): "
for ((i=1; i<$adapters_len-1; i++ )) ;do
    db=$(( adapters[i] - adapters[i-1] ))
    da=$(( adapters[i+1] - adapters[i] ))
    if [ $db -lt 3 ] && [ $da -lt 3 ] ; then
        count=$((count+1))
        r=$(( r + 1 )) 
        printf "${RED}%s${NC} " "${adapters[i]}"
    else
        printf "%s " "${adapters[i]}"
        if [[ $count != 0 ]]; then
            rv=(${rv[@]} $count) 
            count=0
        fi
    fi
done
echo
echo "Total Redundancy: $r"
echo "Consecutive redundancies [${rv[@]}] "

# In my input data there are:
# - no adapters with a difference of 2jolts
# - no more than 3 consecutive redundant adapters

# 1- and 2-consecutive redundant adapters can be suppressed with no condition
# => The cardinality of the Power Set gives the possible suppression
# 1-consecutive ---> 2**1 = 2
# 2-consecutive ---> 2**2 = 4

# for 3-consecutive redundant adapters, at least one adapter must be preserved
# therefore the elimination of all 3 is forbidden
# 3-consecutive ---> 2**3 -1 = 7 semplification possibilities

# The possibilities of each group of redundant adapters are multiplied to obrain the final result

s2=1
p=1
for v in ${rv[@]};do
    case $v in
    1|2) p=$(( 2**v ));;
    3) p=7;;
    *)
        echo "ERROR: more than 3 consecutive redundant adators detected"
        exit 1
    esac
    s2=$(( s2 * p ))
done

echo
echo "Solution 2: $s2"


