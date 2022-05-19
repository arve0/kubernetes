#!/usr/bin/env bash

touch usernames
adjectives=$(wc -l adjectives.txt | tr -s " " | cut -f 2 -d " ")
names=$(wc -l names.txt | tr -s " " | cut -f 2 -d " ")
n=${1:-1}

for (( i=1; i<=n; i++ )); do
   r=$((1 + $RANDOM % adjectives))
   rr=$((1 + $RANDOM % adjectives))
   adjective=$(tail -n+$r adjectives.txt | head -n 1)
   name=$(tail -n+$rr names.txt | head -n 1)
   echo $adjective'-'$name
done