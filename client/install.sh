#!/bin/bash


# Define the URLs for the malware detection script and the log reporter one
URL_MALWARE="http://$1/blacklister.sh"
URL_REPORTER="http://$1/reporter.sh"


# Using some ANSII escape codes in order to provide coloring
RED="\e[31;1m"
GREEN="\e[32;1m"
YELLOW="\e[33;1m"
ANSII_END="\e[0m"


# Debug cleanup
systemctl stop blacklister 2> /dev/null
systemctl disable blacklister 2> /dev/null
rm /etc/systemd/system/blacklister.service 2> /dev/null
systemctl stop reporter 2> /dev/null
systemctl disable reporter 2> /dev/null
rm /etc/systemd/system/reporter.service 2> /dev/null
systemctl daemon-reload 2> /dev/null
systemctl reset-failed 2> /dev/null


# Create a functions that check if a specific command ended with an error or not. If any error occured, display a message and exit
function check_status {
	"${@:1:($#-1)}"
	local status=$?
	local last_param=${@: -1}
	if [ $status -gt 0 ]
	then
		echo -e $last_param
		exit 1
	fi
}


# Function that tests if 2 parameters are equals. If they differ, prints a message and exists the script
function test_statement {
	if [[ "$1" != $2 ]]
	then
		echo -e $3
		exit 1
	fi
}


# Function that can set up a service given the script URL and service name
function create_service {
	echo -e $YELLOW"=================== Setting up the $2 service ==================="$ANSII_END


	# Download the blacklister script and set it properly
	check_status wget $1 -q -O $2.sh --timeout=2  --tries=2 $RED"[!] The resource is unavailable. Please check your internet connection!"$ANSII_END
	echo -e $GREEN'[+] Script downloaded successfully.'$ANSII_END


	mv $2.sh /usr/local/bin/
	chmod 755 /usr/local/bin/$2.sh


	# Create a new service on the host and set it properly
	cat <<- EOF > /etc/systemd/system/$2.service
	[Unit]
	Description=$2 service
	After=network.target

	[Service]
	ExecStart=/bin/bash /usr/local/bin/$2.sh $3
	Restart=always
	RestartSec=3

	[Install]
	WantedBy=default.target
	EOF


	check_status chmod 664 /etc/systemd/system/$2.service $RED"[!] Something bad happened while setting up the service."$ANSII_END
	check_status systemctl daemon-reload $RED"[!] Something bad happened while setting up the service."$ANSII_END
	check_status systemctl enable $2.service 2> /dev/null $RED"[!] Something bad happened while setting up the service."$ANSII_END
	check_status systemctl start $2.service $RED"[!] Something bad happened while setting up the service."$ANSII_END


	echo -e $GREEN"[+] Service created and successfully started."$ANSII_END
}


# Check if script is ran as root
test_statement `whoami` "root" $RED"[!] You must be root to run this."$ANSII_END


# Check if IP/domain is given as the parameter
test_statement $# "1" $RED"[!] Please provide the script ONE argument ONLY which should be the server IP"$ANSII_END


# Setting up the malware detection service
create_service $URL_MALWARE blacklister


# Setting up the log reporter service
create_service $URL_REPORTER reporter $1
echo -e $YELLOW"======================================================================="$ANSII_END