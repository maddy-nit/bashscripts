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
		timeout --preserve-status --kill-after=$TIMEOUT -s SIGINT $TIMEOUT cat $tc_in|$COMMAND>out$index 2>error$index
    #$COMMAND>out$index 2>error$index & sleep $TIMEOUT;kill $!

    # scaling exitcode by 128
    exitcode=`expr ${PIPESTATUS[0]} - 128`    
    execution_time=$((`date +%s%N | cut -b1-13`-start))

    #converting execution time from ms to seconds
    execution_time=$(printf %.3f\\n "$((10**9 * "$execution_time"/1000))e-9")

    if (( exitcode == -128 )); then 
      exitcode=0;
    fi
    #if (( exitcode == 0 & execution_time > `expr $TIMEOUT*1000`)); then execution_time=TIMEOUT; fi
    
    # Runtime Error verification
		if [ ! $exitcode -eq 0 ]; then
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
  delete_temporary_files
fi
exit 0;