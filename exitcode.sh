#!/bin/bash

start=`date +%s%N | cut -b1-13`
docker exec -t Tkc3aDRvM0FONzZjZUlpQzNrYnJwQ2g1anljZ28wSllydDNLNGhJbVFrYVkxc1VjRzB6bUZrUmpxSVRxMDB6OA /bin/bash -c "cat /tmp/FxtQVEwyWA4/kZjpLReWfqBo5VeB7epKzJ+2+qjJPAVhBQUgZ/lPueigikMQ245ymxVNo7rMEwcCMJkF4qVZoL1C9xwphfpbFm3zlavHDs7tK3hk1k83VIOQw0tFRuDn/input46099.txt|./CandidateCode.out>out 2>error"

runtime=$((`date +%s%N | cut -b1-13`-start))
echo $runtime

if [ $? -eq 0 ]
then
	echo "Success"
else
	echo "Run Time Error" >&2
fi
