#!/bin/bash


# Define the local port that the  will use in order to receive messages from clients
PORT=1337


# The file that will store all incomming news
LOGFILE='/root/log.txt'
test -f "$LOGFILE" || touch $LOGFILE


# Listen for any incomming message and place it in the log file
i=0
nc -klp $PORT >> $LOGFILE &


# Check if there is any new line in logfile and print it to stdout
while true
do
	new_i=`wc -l < $LOGFILE`
	if [[ $i -ne $new_i ]]
	then
		awk "NR<"$new_i"&&NR>"$i $LOGFILE
		i=$new_i
	fi
done