#!/bin/bash


# Define the local port that the  will use in order to receive messages from clients
PORT=1337


# The file that will store all incomming news
LOGFILE='./log.txt'


test -f "$LOG_FILE" || touch $LOG_FILE
while true
do
	# Listen for any incomming message and place it in the log file
	nc -lp $PORT >> $LOGFILE
	echo "[+] Received `tail -n5 $LOGFILE`"
done