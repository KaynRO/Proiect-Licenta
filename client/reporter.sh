#!/bin/bash


# The server IP will be given as argument to the script. The PORT is statically defined but can be changed.
SERVER_IP=$1
SERVER_PORT=1337


# Define the logfile where the script that detects malware will output it's results
LOGFILE="/root/log.txt"


# A temporary files that hold the newly added lines to the logfile
TMP_FILE='/tmp/.new_lines.tmp'


i=0
while true
do
	# Get the first 3 lines from the logfile (equivalent to one alert entry) and put the information
	# in a tmp file. This should happen if there are new entries in the logfile which can be counted
	# at each iteration
	new_i=`wc -l < $LOGFILE`
	if [[ $i -ne $new_i ]]
	then
		lines="`awk 'NR<='$new_i'&&NR>'$i $LOGFILE | sed 's/\[+\]/   /g' | sed 's/^/    /g'`"
		echo -e "[+] New alert from `hostname`@`hostname -I | sed 's/ //g'`:\n$lines" > $TMP_FILE
		i=$new_i

		# Send the tmp file to the server and cause a small delay.
		nc -w 3 $SERVER_IP $SERVER_PORT < $TMP_FILE
		sleep 1
	fi
done

