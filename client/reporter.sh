	#!/bin/bash


# The server IP will be given as argument to the script. The PORT is statically defined but can be changed.
SERVER_IP=$1
SERVER_PORT=1337


# Define the logfile where the script that detects malware will output it's results
LOGFILE="/root/log.txt"


# A temporary files that hold the newly added lines to the logfile
TMP_FILE='/tmp/.new_lines.tmp'


while true
do
	# If the logfile is not empty, extract one alert entry (4 lines) and consume them by sending to the server
	if [[ `wc -l < $LOGFILE` -ne "0" ]]
	then
		lines="`head -n4 $LOGFILE | sed 's/\[+\]/   /g' | sed 's/^/    /g'`"
		echo -e "[+] New alert from `hostname`@`hostname -I | sed 's/ //g'`:\n$lines" > $TMP_FILE

		# Make sure to make the logfile not immutable before removing lines and add the attribute after
		chattr -i $LOGFILE
		sed -i '1,4d' $LOGFILE
		chattr +i $LOGFILE

		# Send the tmp file to the server and cause a small delay.
		nc -w 3 $SERVER_IP $SERVER_PORT < $TMP_FILE
		sleep 1
	fi
done

