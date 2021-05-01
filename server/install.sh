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


# Check if PORT is given as the parameter
test_statement $# "1" $RED"[!] Please provide the script 1 argument ONLY which should be the local port to listen."$ANSII_END


# Install and run apache2 in order to host the webserver
check_status apt-get install --yes --quiet apache2 $RED"[!] Apache2 could not be installed!"$ANSII_END
check_status service apache2 start $RED"[!] Apache2 could not be started!"$ANSII_END
echo -e $GREEN"[+] Apache2 up and running."$ANSII_END


# Download all the necessary files from the Github repository.
#check_status curl --silent https://raw.githubusercontent.com/KaynRO/Proiect-Licenta/main/server/server.sh?token=AEK5VX6OLAZ6ZFIVYSSMQZ3ARVNXQ > /root/server.sh $RED"[!] server.sh script failed while downloading!"$ANSII_END
#check_status curl --silent https://raw.githubusercontent.com/KaynRO/Proiect-Licenta/main/client/blacklister.sh?token=AEK5VX7EL2EXBC34FCXUA4TARVNZ4 > /var/www/html/blacklister.sh $RED"[!] blacklister.sh script failed while downloading!"$ANSII_END
#check_status curl --silent https://raw.githubusercontent.com/KaynRO/Proiect-Licenta/main/client/reporter.sh?token=AEK5VX5SGEPUI4DAOZML2YTARVN2O > /var/www/html/reporter.sh $RED"[!] reporter.sh script failed while downloading!"$ANSII_END
cd /tmp ; git clone https://github.com/KaynRO/Proiect-Licenta ; cd Proiect-Licenta
cp /server/server.sh /root/server.sh
cp /client/blacklister.sh /var/www/html/blacklister.sh
cp /client/reporter.sh /var/www/html/reporter.sh
echo -e $GREEN"[+] Files successfully downloaded."$ANSII_END


# Move the server.sh file inside root directory and start it
check_status bash /root/server.sh $PORT $RED"[!] Something bad happened while running server.sh!"$ANSII_END
echo -e $GREEN"[+] server.sh started successfully."$ANSII_END