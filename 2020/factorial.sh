#/bin/bash

# calculate the factorial  of n
n=$1
p=1
for i in $( seq 1 $n ); do
    p=$((p*i))
done
echo $p

