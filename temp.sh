#!/bin/bash

STR="Sarah;Lisa;Jack;Rahul;Johnson"  #String with names
IFS=';' read -ra NAMES <<< "$STR"    #Convert string to array

#Print all names from array
for i in "${NAMES[@]}"; do
    echo $i
done
