#!/bin/bash


# Define API Key to be used for HybridAnalysis, Logfile, Quarantine directory as well as system hostname.
API_KEY="y8h1wkc8fd8afc85d3shu7foa91f4d63mu2hkeji0aa425dbdrevqgfzc878cafd"
HOSTNAME=`hostname`
LOGFILE="/root/log.txt"
QUARANTINE="/root/quarantine"


function init(){
	# Create the quarantine directory as well as the log file. To avoid any change of the logfile, which could cause
	# malware not being detected, set file attribute to immutable. This can also be used as a syncronization mechanism
	mkdir $QUARANTINE 2> /dev/null
	chmod -R 660 $QUARANTINE
	touch $LOGFILE 2> /dev/null
	chattr +i $LOGFILE

}


function isolate_file(){
	# If file is malicious or suspicious, move them to a temp folder, change owner to root and change permissions.
	# Also, make the file immutable to assure no one ever touches it in any way.
	mv $1 $2
	chown root:root $2
	chmod 600 $2
	chattr +i $2
}


function process_file(){
	# Construct the curl request to the API using the official schema.
	submission_name="`hostname`_`hostname -I | sed 's/ //g'`_`date +'%s'`_`echo $1 | awk -F '/' '{print $NF}'`"
	resp=`curl -X POST --silent \
					-H "User-Agent: Falcon Sandbox" \
					-H "Accept: application/json" \
					-H "Content-Type: multipart/form-data" \
					-H "Api-Key: $API_KEY" \
					-F "scan_type=all" \
					-F "no_share_third_party=false" \
					-F "allow_community_access=true" \
					-F "submit_name=$submission_name" \
					-F "file=@$1" \
					"https://www.hybrid-analysis.com/api/v2/quick-scan/file"`

	# If file is not empty.
	if [[ $resp != *"An empty file is not allowed"* ]]
	then
		id=`echo $resp | jq .id | sed 's/\"//g'`
		finished=`echo $resp | jq .finished`
		sha256=`echo $resp | jq .sha256 | sed 's/\"//g'`

		# If file has not been fully analyzed yet, retry until it's done.
		while [[ "$finished" == "false" ]]
		do
			sleep 0.1
			resp=`curl -X GET --silent \
					-H "User-Agent: Falcon Sandbox" \
					-H "Accept: application/json" \
					-H "Api-Key: $API_KEY" \
					"https://www.hybrid-analysis.com/api/v2/quick-scan/$id"`
			finished=`echo $resp | jq .finished`
		done

		# See if any of the scanners responded with 'suspicious' or 'malicious' and isolate the file is so. 
		# To append to logfile, delete immutable attribute first, append then add it back.
		malicious=`echo $resp | jq '.scanners[].status | contains("malicious")'`
		suspicious=`echo $resp | jq '.scanners[].status | contains("suspicious")'`
		if [[ $malicious == *"true"* ]] || [[ $suspicious == *"true"* ]]
		then

			fn="$QUARANTINE/$submission_name"
			chattr -i $LOGFILE
			echo -e "[+] New suspicious/malicious file: $1\n    Scan URL: https://www.hybrid-analysis.com/sample/$sha256\n    Quarantined: $fn\n    Timestamp: `date +'%R %d/%m/%Y'`" >> $LOGFILE
			chattr +i $LOGFILE
			isolate_file $1 "$fn"
		fi
	fi
}


init

while true
do
	# Check every 6 seconds for new fles on the system. As users should only have write access to their home directory ONLY, monitor that directory only.
	# This can be easiliy changed to match multiple directories or match all except some (-not -path)
	new_files=`find /home -ignore_readdir_race -type f -mmin -0.1 2> /dev/null`

	# Submit them to HybridAnalysis by spawning the function in the background.
	for i in $new_files
	do
		process_file $i &
	done

	# Sleep for 5 seconds to avoid duplicate new file detection
	sleep 5
done

