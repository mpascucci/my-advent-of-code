#/bin/bash

# calculate the nPk permutations (possible orers) of k elements out of n
# eg if n={1,2,3}
# 12 21 23 32 13 31 are 6 possible permutations 
n=$1
k=$2

p=1
for i in $( seq $((n-k+1)) $((n)) ); do
    #echo $i
    p=$((p*i))
done

echo $p


