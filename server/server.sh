#!/bin/bash


# Define the local port that the  will use in order to receive messages from clients
PORT=$1


# The file that will store all incomming news
LOG_FILE='./log.txt'


test -f "$LOG_FILE" || touch $LOG_FILE
while true
do
	# Listen for any incomming message and place it in the log file
	nc -lp $PORT >> $LOG_FILE
	echo "[+] Received `tail -n1 $LOG_FILE`"
done