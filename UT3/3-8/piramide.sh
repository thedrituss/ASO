#!/bin/bash
#
# Pirámide según parámetro


for ((i=1; i<=$1; i++)); do
    for ((j=1; j<=i; j++)); do
        echo -n "$i"
    done
    echo
done

for ((i=1; i<=$1; i++)); do
    for ((j=1; j<=i; j++)); do
        printf "%s" "$i"
    done
    # Print a newline after the inner loop finishes
    printf "\n"
done
