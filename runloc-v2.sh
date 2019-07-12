#!/bin/bash
#
# This script takes three arguments 
#   $1 - TC_FOLDER_NAME(Test case folder name)
#   $2 - COMMAND(Command to be execured)
#   $3 - TIMEOUT(Test case time out)
# e.g bash /bashworkspace/runloc.sh /tmp/tcdata ./CandidateCode.out .1
#Written by 'Monti Chandra'
#Dated 02/07/2019

TC_FOLDER_NAME=$1
COMMAND=$2
TIMEOUT=$3

#Extract test case id from input.txt file location
# Arg $1 - test case input file location
extract_tcid(){
  location=$1
  location=${location/"input"/" "}
  location=${location/".txt"/" "}
  tcid="$(echo $location | cut -d' ' -f2)"
  printf "$tcid"
  return
}

clear_candidate_directory(){
  rm -Rf response*> /dev/null;rm -Rf out*> /dev/null;rm -Rf error*> /dev/null;rm -Rf core.*> /dev/null
}

delete_temporary_files(){
  rm -Rf out*> /dev/null;rm -Rf error*> /dev/null;rm -Rf core.*> /dev/null
}

#####################################################################
# Evaluate a floating point number conditional expression.
function float_cond(){
    local cond=0
    if [[ $# -gt 0 ]]; then
        cond=$(echo "$*" | bc -q 2>/dev/null)
        if [[ -z "$cond" ]]; then cond=0; fi
        if [[ "$cond" != 0  &&  "$cond" != 1 ]]; then cond=0; fi
    fi
    local stat=$((cond == 0))
    return $stat
}

start_execute(){
  printf "[" >> response
  i=0
  tccount=$(ls -dq $TC_FOLDER_NAME/input*|wc -l)

  ls -dq $TC_FOLDER_NAME/input* | while read -r tc_in ; do    
    ((i++))
    # stats variable
    index=''
    status='false'
    execution_time=null
    runtime_error_flag='false'
    time_limit_exceeded='false'
    memory_limit_exceeded='false'
    error=''


    index=$(extract_tcid "$tc_in")
    start=`date +%s%N | cut -b1-13`
    
    # Starting execution
    #execute command in background
    (cat $tc_in|$COMMAND>out$index 2>error$index) &

    #get process ID
    proc=$! 
    exitcode=$?

    #sleep for 10 milliseconds then kill command
    (sleep $TIMEOUT; if kill -9 $proc > /dev/null 2>&1; then
      exitcode=130
    fi) &

    # scaling exitcode by 128
    exitcode=`expr $exitcode - 128`    
    execution_time=$((`date +%s%N | cut -b1-13`-start))

    #converting execution time from ms to seconds
    execution_time=$(printf %.3f\\n "$((10**9 * "$execution_time"/1000))e-9")

    if (( exitcode == -128 )); then 
      exitcode=0;
    fi
    
    # Runtime Error verification
    if [ ! $exitcode -eq 0 ]; then
      execution_time=null
      case "$exitcode" in
      2)  time_limit_exceeded='true'
            error="Time Limit Exceeded"
          ;;
      9)  memory_limit_exceeded='true'
            error="Memory Limit Exceeded"
          ;;
        *)  runtime_error_flag='true'
            error="Runtime error"
          ;;
      esac
    else
      # output verification (if output file available and exit code is 0)
      if ([ -f "out$index" ] && [ $exitcode -eq 0 ]); then
        cat "out$index"; exit 0;
        if [[ ! $(diff out$index ${tc_in/"input"/"output"}) ]]; then
          status=true
        fi
      fi
    fi

    printf "{\"index\": $index, \"isPassed\": $status, \"executionTime\": \"$execution_time\", \"runtimeErrorFlag\": $runtime_error_flag, \"outOfTime\": $time_limit_exceeded, \"outOfMemory\": $memory_limit_exceeded, \"errorMessage\": \"$error\"}" >> response
    if (( i < tccount )); then printf "," >> response; fi
    done  
  printf "]" >> response
}

# Boot start
if ([ "$0" = "$BASH_SOURCE" ] || ! [ -n "$BASH_SOURCE" ]); then 
  clear_candidate_directory
  # intiating execute
  start_execute "$@"
  #delete_temporary_files
fi
exit 0;