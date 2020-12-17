#/bin/bash
# calculate the exact factorial  of $1

n=$1
p=1
for i in $( seq 1 $n ); do
    p=$((p*i))
done
echo $p

