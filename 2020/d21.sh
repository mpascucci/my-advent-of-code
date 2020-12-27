#!/bin/bash

# Load data
if [[ -z $1 ]]; then
        echo "Error: A file must be specified as first argument"
        exit 1
else
    fname=$1
fi
declare -A algs
declare line incredients

while read line; do
    ingredients=${line% (*}
    allergenes=${line#*(contains }
    allergenes=${allergenes%)} # remove last parenthesis
    allergenes=${allergenes//,/} # remove commas

    for alg in $allergenes;do
        for ing in $ingredients;do
            if ! [[ ${algs[$alg]} =~ $ing ]];then
                algs[$alg]+=" $ing"
            fi
        done
    done
done < $fname

declare -p algs
