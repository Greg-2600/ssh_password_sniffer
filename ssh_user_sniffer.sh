#!/bin/bash

get_users() {
# extract user names from the authorization system log
	user=$(cat /var/log/auth.log|
	grep "user="|
	awk {'print $15'}|
	cut -f2 -d'='|
	grep "[a-z]"|
	tail -1)

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

# iterate through the auth log every 3 seconds
# track the last user found
last=""
while [ 1 ]; do
	result=$(get_users)
	if [ "$last" != "$result" ]; then
		echo $result
		last=$result
	fi
	sleep 3
done
