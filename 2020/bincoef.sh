#/bin/bash
# calculate the (k n) binomial coefficient
# this gives the permutations of k elements out of n, disregarding order
# eg if n={1,2,3} has 3 such possible permutations (e.g. 12,13,23)

n=$1
k=$2

nmk=$((n-k))

if [ $nmk -ge $k ]; then
    p=$( ./perm.sh $n $nmk )
    f=$( ./factorial.sh $nmk )
else 
    p=$( ./perm.sh $n $k)
    f=$( ./factorial.sh $k )
fi

echo $((p/f))

