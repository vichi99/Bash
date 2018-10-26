#!/bin/bash

NAME=${0##*/}
VER="1.0"
LINE="-----------------------------------------------------------------------"

	hostname=$1	
	path=$2
	user=$3
	http=$4 #www.het.brown.edu/guide/UNIX-password-security.txt #-random txt k otestovani


connect_ssh()
{
	ssh -i ${path} ${user}@${hostname} 2>dev/null && echo "Connected to ${hostname} server" || { echo "Connecting to ${hostname} server....error"; exit 1 ; }
	cd / 
}
	
main()
{
		

	#check user
	if id "$user" >/dev/null 2>&1 ;then
	        echo "Checking user $user.....OK"
	else
		echo "Checking user $user.....error"
		if useradd -m -s /bin/bash ${user} 2>dev/null  ;then
			echo "Adding user $user.....OK"
		else
			echo "Adding user $user.....error"
			exit 1
		fi    	
	fi 


	#check .ssh directory
	if [ -d /home/${user}/.ssh ] ;then
		echo "Check if directory exists /home/${user}/.ssh.....OK"
	else
		echo "Check if directory exists /home/${user}/.ssh.....error"
		if mkdir home/${user}/.ssh 2>dev/null ;then
			echo "Making directory /home/${user}/.ssh.....OK"
		else
			echo "Making directory /home/${user}/.ssh.....error"
			exit 1
		fi
	fi

	

	#check authorized_keys file
	if [ -f /home/${user}/.ssh/authorized_keys ] ;then 
		echo "Check if file exists /home/${user}/.ssh/authorized_keys.....OK"
		if grep -q " ${user}@" /home/${user}/.ssh/authorized_keys ;then
			echo "Check if file /home/${user}/.ssh/authorized_keys contains $user key.....OK"
				
		else   	
			echo "Check if file /home/${user}/.ssh/authorized_keys contains $user key.....error.....Key will be downloaded at next steps"		 
			download #download and insert key
		fi 
	else
		echo -e "Check if file exists /home/${user}/.ssh/authorized_keys.....NOK.....File will be created at next steps"	
		download #download and insert key		
	fi	


}

download()
{
	ping -c1 google.com &>/dev/null && echo "Check internet conection.....OK" || { echo "Check internet conection.....error"; exit 1; }

	if wget -O /home/${user}/.ssh/${user}_rsa.pub ${http} 2>dev/null ;then
		echo "Downloading key into /home/${user}/.ssh/${user}_rsa.pub.....OK"
		if grep -q " ${user}@" /home/${user}/.ssh/${user}_rsa.pub  ;then
			echo "Check if downloaded file contains key for ${user} user.....OK"
		else
			echo -e "Check if downloaded file contains key for ${user} user.....error\nProbably was downloaded bad key from link"
			exit 1
		fi
	else
		echo "Downloading key into /home/${user}/.ssh/${user}_rsa.pub.....error"
		exit 1 
	fi

	#grep -q /home/${user}/.ssh/${user}_rsa.pub /home/${user}/.ssh/authorized_keys && echo "ok" || echo "error"


	if  cat /home/${user}/.ssh/${user}_rsa.pub >> /home/${user}/.ssh/authorized_keys 2>dev/null ;then
		echo "Moving key into home/${user}/.ssh/authorized_keys.....OK"
		if grep -q " ${user}@" /home/${user}/.ssh/authorized_keys  ;then
		#zde je mensi nedostatek kde neoveruji zcela kompletni key ale jen user name
			echo "Check if authorized_keys contains key for ${user} user.....OK"
		else
			echo -e "Check if authorized_keys contains key for ${user} user.....error\nProbably downloaded bad key from link"
		exit 1
		fi
	else
		echo "Moving key into home/${user}/.ssh/authorized_keys.....error"
		exit 1
	fi
	
}

if [[ $1 == "-h" || $1 == "-help" ||  $# == 0 ]];then
	echo -e "$LINE\nHelp for $NAME script :: version $VER\n$LINE\nUsage:\n\t<hostname> <path_to_key> <user_name> <http_to_key>\n\tProgram is checking public key for ssh communication\n$LINE"
elif [[ $1 != "-h" ]] && [[ $# == 4 ]];then
	connect_ssh
	main && echo "Script was successfully finished" || { echo "Script has some problems"; exit 1; } 
else
	echo -e "Bad input.\nExiting..."
	exit 1
fi
