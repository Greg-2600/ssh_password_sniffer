#!/bin/bash

get_users() {
	user=$(cat /var/log/auth.log|
	grep "user="|
	awk {'print $15'}|
	cut -f2 -d'='|
	grep "[a-z]"|
	tail -1)

	#pass=$(cat strace.out|grep "read(6,"| grep '\\f\\0\\0\\0'|awk {'print $4'}|sed 's/\\f\\0\\0\\0//g'|sed 's/\\[0-9][0-9]//g'|sed 's/\\[0-9]//g'|sed 's/\\n//g'|sed 's/\",//g'|sed 's/^\"//g'|sed 's/\\f//g'|sed 's/\\t//g'|sed 's/\\v//g'>passwords;cat passwords|tail -1)
	#pass:$pass"
	#echo "pass:$pass"
	echo "user:$user"
}


check_root() {
# check if user running this is root 
# if not give instructions and exit
	if ((${EUID:-0} || "$(id -u)")); then
		echo "This script must be run as root: sudo $0" 
		exit 1
	fi
}


# strace must be run as root as ssh is also
check_root

last=""
while [ 1 ]; do
	result=$(get_users)
	if [ "$last" != "$result" ]; then
		echo $result
		last=$result
	fi
	# echo "last: $last checking..."
	sleep 3
done
