#!/bin/bash


# Using some ANSII escape codes in order to provide coloring
RED="\e[31;1m"
GREEN="\e[32;1m"
YELLOW="\e[33;1m"
ANSII_END="\e[0m"


# Function that tests if 2 parameters are equals. If they differ, prints a message and exists the script
function test_statement {
	if [[ "$1" != $2 ]]
	then
		echo -e $3
		exit 1
	fi
}


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


# Check if script is ran by root
test_statement `whoami` "root" $RED"[!] You must be root to run this."$ANSII_END


# Install and run apache2 in order to host the webserver
check_status apt-get install -qq apache2 $RED"[!] Apache2 could not be installed!"$ANSII_END
check_status service apache2 start $RED"[!] Apache2 could not be started!"$ANSII_END
echo -e $GREEN"[+] Apache2 up and running."$ANSII_END


# Download all the necessary files from the Github repository.
check_status curl --silent pls.codwerlabs.com/kaynsupersecretfolder/server.sh > /root/server.sh $RED"[!] server.sh script failed while downloading!"$ANSII_END
check_status curl --silent pls.codwerlabs.com/kaynsupersecretfolder/blacklister.sh > /var/www/html/blacklister.sh $RED"[!] blacklister.sh script failed while downloading!"$ANSII_END
check_status curl --silent pls.codwerlabs.com/kaynsupersecretfolder/reporter.sh > /var/www/html/reporter.sh $RED"[!] reporter.sh script failed while downloading!"$ANSII_END
check_status curl --silent pls.codwerlabs.com/kaynsupersecretfolder/install.sh > /var/www/html/install.sh $RED"[!] reporter.sh script failed while downloading!"$ANSII_END
echo -e $GREEN"[+] Files successfully downloaded."$ANSII_END


# Move the server.sh file inside root directory and start it
echo -e $GREEN"[+] Running server.sh."$ANSII_END
bash /root/server.sh