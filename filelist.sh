#!/bin/bash
files=$( ls * )
counter=0
for i in $files ; do
  echo Next: $i
  let counter=$counter+1
  echo $counter
done