#!/bin/bash
this_fname=$( basename "$0" | cut -f 1 -d '.' )
data_fname="${this_fname}_data.txt"
w=
i=0
declare -A content
declare -A quantity
bags=""

echo "Loading data..."
while read line; do
    bag=$( sed -r 's/^([[:alpha:]]+)\s([[:alpha:]]+)\sbags.*$/\1\2/' <<< $line )
    bags="$bags $bag"
    contain=$( sed -r 's/^.*contain\s(.*)\.$/\1/' <<< $line )
    contain=$( sed -r 's/([[:digit:]]+)\s([[:alpha:]]+)\s([[:alpha:]]+)\sbag[s]?[,]*/\1-\2\3/g' <<< $contain )
    contain=$( sed -r 's/no other bags/0-nootherbags/g' <<< $contain )
    n=""
    t=""
    for c in $contain; do
        num_type=($( tr '-' ' '<<< $c ))
        n="$n ${num_type[0]}"
        t="$t ${num_type[1]}"
    done
    content[$bag]=$t
    quantity[$bag]=$n
    
    #echo $bag, $contain, $n
done < $data_fname

#depth=0

contains_sg () {
    # check if a box contains the good box (specified in global var)
    local in_bags=${content[$1]}
    local this_bag
    #echo "$depth: $1 [${in_bags[*]}]"
    for this_bag in $in_bags; do
        if ! [[ $bad_bags =~ $this_bag ]]; then
            if [[ $good_bags =~ $this_bag ]]; then
                found=1
            else
                #depth=$(( depth + 1 ))
                contains_sg $this_bag
            fi
        fi
        if [[ $found == 1 ]]; then break; fi
    done
    #depth=$(( depth - 1 ))
    #echo "found:$found"

}

contain_n () {
    # count boxes in a given box
    local in_bags=${content[$1]}
    local in_quant=(${quantity[$1]})
    local this_bag
    local i=0
    local boxes=0
    local this_boxes sub_boxes
    #echo "$1 [$in_bags]<${in_quant[*]}>" >&2
    for this_bag in $in_bags; do
        #echo "$this_bag" >&2
        this_boxes=${in_quant[$i]}
        sub_boxes=$( contain_n $this_bag )
        boxes=$(( boxes + this_boxes*( sub_boxes + 1 ) ))
        i=$(( i+1 ))
    done
    echo $boxes
}

good_bags="shinygold"
bad_bags="nootherbags"

n_good=0
n_bags=0
for bag in $bags; do
    if [[ $bag == "shinygold" ]]; then
        continue
    fi
    found=0
    contains_sg $bag
    if [[ $found == 1 ]]; then
        good_bags="$good_bags $bag"
        n_good=$(( n_good+1 ))
    else
        bad_bags="$bad_bags $bag"
    fi
    n_bags=$((n_bags+1))
    #echo "$bag, $ans : $n_good/$n_bags"
    printf "\r\033[K Bags containing shiny gold... $n_good/$n_bags"
    #echo ">>> (${good_bags[*]})"
    #echo "<<< (${bad_bags[*]})"
done

echo
echo "Solution 1: $n_good"
echo "Solution 2: $( contain_n 'shinygold' )"
