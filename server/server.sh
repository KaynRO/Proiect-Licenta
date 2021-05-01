#!/bin/bash


# Define the local port that the  will use in order to receive messages from clients
PORT=1337


# The file that will store all incomming news
LOGFILE='./log.txt'


test -f "$LOGFILE" || touch $LOGFILE
while true
do
	# Listen for any incomming message and place it in the log file
	nc -lp $PORT >> $LOGFILE
	echo -e "[+] Received:\n`tail -n4 $LOGFILE`"
done