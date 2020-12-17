#!/bin/bash
this_fname=$( basename "$0" | cut -f 1 -d '.' )
data_fname="${this_fname}_data.txt"

required_fields=( "byr" "iyr" "eyr" "hgt" "hcl" "ecl" "pid" )

is_valid_passport() {
    local raw_line=$1
    # transform into array
    line=($raw_line)
    #echo "line ${line[*]}"

    #declare associative array
    declare -A document 
    # fill the array with the given fields
    for item in ${line[*]};do
        local key=${item%:*}
        local value=${item#*:}
        #echo $key,$value
        document[$key]=$value
    done
    
    # the array keys
    local doc_keys=${!document[@]}
    
    #check validity
    valid=1
    for key in ${required_fields[*]}; do
        #echo "$key:${document[$key]}"
        if [[ -z ${document[$key]} ]];then
            valid=0; break
        fi
        
        local val

        # check byr
        if [[ $key == "byr" ]]; then
            val=${document[$key]}
            if [[ ${#val} != 4 ]];then
                valid=0
                break
            fi
            if [[ $val -lt 1920 ]] || [[ $val -gt 2002 ]]; then
                valid=0
                break
            fi
        fi

        # check iyr
        if [[ $key == "iyr" ]]; then
            val=${document[$key]}
            if [[ ${#val} != 4 ]];then
                valid=0
                break
            fi
            if [[ $val -lt 2010 ]] || [[ $val -gt 2020 ]]; then
                valid=0
                break
            fi
        fi

        # check eyr
        if [[ $key == "eyr" ]]; then
            val=${document[$key]}
            if [[ ${#val} != 4 ]];then
                valid=0; break
            fi
            if [[ $val -lt 2020 ]] || [[ $val -gt 2030 ]]; then
                valid=0; break
            fi
        fi

        # check hgt
        if [[ $key == "hgt" ]]; then
            val=${document[$key]}
            local unit=${val: -2}
            local num=${val:0: -2}
            #echo $unit
            if [[ $unit == "cm" ]]; then
                if [[ $num -lt 150 ]] || [[ $num -gt 193 ]]; then
                      valid=0; break     
                fi
            elif [[ $unit == "in" ]]; then
                if [[ $num -lt 59 ]] || [[ $num -gt 76 ]]; then
                      valid=0; break     
                fi
            else
                valid=0; break
            fi
        fi

        # check hcl
        if [[ $key == "hcl" ]]; then
            val=${document[$key]}
            if ! [[ $val =~ ^#[0-9abcdef]{6}$ ]];then
                valid=0; break
            fi
        fi

        # check ecl
        if [[ $key == "ecl" ]]; then
            val=${document[$key]}
            if ! [[ $val =~ ^amb|blu|brn|gry|grn|hzl|oth$ ]];then
                valid=0; break
            fi
        fi

        # check pid
        if [[ $key == "pid" ]]; then
            val=${document[$key]}
            if ! [[ $val =~ ^[0-9]{9}$ ]];then
                valid=0; break
            fi
        fi
    
    done

}

## === Data Preprocessing using SED, TR and READARRAY
## change empty lines into a custom split symbol
#data_str=$( sed -r "s/^$/\|/" $data_fname )
## change newlines into space (use tr because sed works per line)
## this works only if the symbol is not already present in the data.
#data_str=$( tr "[\n\r]+" " " <<< $data_str)
#readarray -t -d "|" data <<< $data_str

## ==== DATA PREPROCESSING WITH csplit
#csplit --quiet --elide-empty-files \
#    --suppress-matched \
#    --prefix "split_" \
#    --digits=5 \
#    $data_fname "/^$/" '{*}'
#
#lines=()
#
#for fname in $( ls split_* );do
#    readarray -t data < $fname
#    line=${data[*]}
#    lines+=("$line")
#done
#
#\rm split_*

## DATA PREPROCESSING line-by-line
block=""
lines=()
while read line; do
    # if the line is empty
    if [[ -z $line ]]; then
        lines+=("$block")
        block=""
    else
        block="$block $line"
    fi
done < $data_fname
lines+=("$block")


## === check all passports
n_valid=0
for line in "${lines[@]}"; do
    is_valid_passport "$line"
    n_valid=$((n_valid+valid))
done

echo "valid passports $n_valid/${#lines[@]}"
