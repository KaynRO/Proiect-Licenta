#!/bin/bash


# The server IP and PORT will be given as parameters to script/service
SERVER_IP=$1
SERVER_PORT=1337


# Define the logfile where the script that detects malware will output it's results
LOGFILE="/root/log.txt"


# A temporary files that hold the newly added lines to the logfile
TMP_FILE='/tmp/.new_lines.tmp'

i=1
while true
do
	# Get the first 3 lines from the logfile (equivalent to one file entry) and put the information
	# in a tmp file. This should happen if there are new entries in the logfile which can be counted
	# at each iteration
	if [[ `wc -l < $LOGFILE` -ge $(($i * 3)) ]]
	then
		lines=`head -n 3 $LOGFILE`
		echo -e "New malicious file found on: `hostname`@`hostname-i`\n"$lines > $TMP_FILE

		# Remove immutable attribute, move the first 3 lines of the logfile to the end and make it immutable again.
		chattr -i $LOGFILE
		sed -i '1,2,3d' $LOGFILE
		echo -e $lines >> $LOGFILE
		chattr +i $LOGFILE

		# Send the tmp file to the server and cause a small delay.
		nc -w 3 $SERVER_IP $SERVER_PORT < $TMP_FILE
		sleep 1
		i=$((i+1))
	fi
done

