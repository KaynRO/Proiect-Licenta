#!/bin/bash


# The server IP and PORT will be given as parameters to script/service
SERVER_IP=$1
SERVER_PORT=$2


# Define the logfile where the script that detects malware will output it's results
LOG_FILE="./log.txt"


# A temporary files that hold the newly added lines to the logfile
TMP_FILE='/tmp/.new_lines.tmp'


# Keep a count on the number of lines of the logfile from the last inspection
old_line_count=`wc -l $LOG_FILE | cut -c1`


while true
do
	# Calculate the current number of lines of the logfile
	new_line_count=`wc -l $LOG_FILE | cut -c1`

	if [[ $new_line_count != $old_line_count ]]
	then
		# If something was added, old != new, then extract the new lines and send them over to the server.
		diff_lines="$(($new_line_count - $old_line_count))"
		echo `hostname -i` `hostname` `tail -n$diff_lines $LOG_FILE` > $TMP_FILE
		nc -w 3 $SERVER_IP $SERVER_PORT < $TMP_FILE
		sleep 5

	fi

	# Update current line count
	old_line_count=$new_line_count
done

