#!/bin/bash
#!/bin/bash
##This script(run) will be use execute all test case(s) as single process inside container 
# docker exec -t <conbtainer_name> /bin/bash -c "sh run"
# Input- Space seperated test case ids as command line arguments
# Output- JSON array of test case response object
# Wriiten by - Monti Chandra

for i in "$@"
do
  	#cat /tmp/FxtQVEwyWA4/kZjpLReWfqBo5VeB7epKzJ+2+qjJPAVhBQUgZ/lPueigikMQ245ymxVNo7rMEwcCMJkF4qVZoL1C9xwphfpbFm3zlavHDs7tK3hk1k83VIOQw0tFRuDn/input46099.txt|./CandidateCode.out>out 2>error
  	start=`date +%s%N | cut -b1-13`
	cat /tmp/FxtQVEwyWA4/kZjpLReWfqBo5VeB7epKzJ+2+qjJPAVhBQUgZ/lPueigikMQ245ymxVNo7rMEwcCMJkF4qVZoL1C9xwphfpbFm3zlavHDs7tK3hk1k83VIOQw0tFRuDn/input$i.txt|./CandidateCode.out>out 2>error | wc -l
	runtime=$((`date +%s%N | cut -b1-13`-start))
	echo $runtime
	echo $?
	if [ $? -eq 0 ]
	then
		echo "Success"
	else
		echo "Run Time Error" >&2
	fi
done