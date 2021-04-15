#!/bin/bash


URL="http://$1/blacklister.sh"
RED="\e[31;1m"
GREEN="\e[32;1m"
ANSII_END="\e[0m"


#Create a functions that check if a specific command ended with an error or not. If any error occured, display a message and exit
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


function test_statement {
	if [[ "$1" != $2 ]]
	then
		echo -e $3
		exit 1
	fi
}


#Check if script is ran as root
test_statement `whoami` "root" $RED"[!] You must be root to run this."$ANSII_END


#Check if IP/domain is given as the parameter
test_statement $# "0" $RED"[!] Please provide the IP/domain as the first argument to the script."$ANSII_END


#Download the blacklister script and set it properly
check_status wget $URL -q -O blacklister.sh --timeout=2  --tries=2 $RED"[!] The resource is unavailable. Please check your internet connection!"$ANSII_END
echo -e $GREEN'[+] Script downloaded successfully'$ANSII_END


mv blacklister.sh /usr/local/bin/
chmod 744 /usr/local/bin/blacklister.sh


#Create a new service on the host and set it properly
cat << EOF > /etc/systemd/system/blacklister.service
[Unit]
After=network.target

[Service]
ExecStart=/usr/local/bin/blacklister.sh

[Install]
WantedBy=default.target
EOF

check_status chmod 664 /etc/systemd/system/blacklister.service $RED"[!] Something bad happened while setting up the service"$ANSII_END
check_status systemctl daemon-reload $RED"[!] Something bad happened while setting up the service"$ANSII_END
check_status systemctl enable blacklister.service $RED"[!] Something bad happened while setting up the service"$ANSII_END
check_status systemctl start blacklister.service $RED"[!] Something bad happened while setting up the service"$ANSII_END

echo -e $GREEN"[+] Service created and successfully started."$ANSII_END
