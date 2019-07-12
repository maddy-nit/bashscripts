#!/bin/bash

num1=2.21
num2=2.31

_output=`echo "$num1 != $num2" | bc`
if [ $_output == "1" ]; then
   echo "$num1 is not equal to $num2"
else
   echo "$num1 is equal to $num2"
fi
