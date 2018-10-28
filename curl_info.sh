#!/bin/bash
#######
#Code through private key provide ssh login to PC. Control if exist user and if not, make
#them and assing ssh public key from http address. Then control if in authorized_keys is exists users
#public key from http, if not, add them.
#does not work on 100%
######


NAME=${0##*/}
VER="1.0"
LINE="-----------------------------------------------------------------------"

parametr=$1
user=$(users)
dir=${0/}

HOST=$HOSTNAMEe
OS=$(lsb_release -s -i -c -r)

cron()
{
	line="*/1 * * * * ${dir}"
	(crontab -u ${user} -l; echo "$line" ) | crontab -u ${user} -
	#musim jeste doresit
}

main()
{



#Memory
memTotal=$(egrep '^MemTotal:' /proc/meminfo | awk '{print $2}')
memFree=$(egrep '^MemFree:' /proc/meminfo | awk '{print $2}')
memCached=$(egrep '^Cached:' /proc/meminfo | awk '{print $2}')
memUsed=$(($memTotal - $memFree))
swapTotal=$(egrep '^SwapTotal:' /proc/meminfo | awk '{print $2}')
swapFree=$(egrep '^SwapFree:' /proc/meminfo | awk '{print $2}')
swapUsed=$(($swapTotal - $swapFree))


#CPU
cpuThreads=$(grep processor /proc/cpuinfo | wc -l)
cpuUtilization=$((100 - $(vmstat 2 2 | tail -1 | awk '{print $15}' | sed 's/%//')))


directory=$(df usr/ -P  -T | tail -n+2 | awk '{print "{" "\"total-space\":" $3 ", \"free-space\":" $5  "},"}';
)




#Result in JSON
JSON="
{
  \"hostname\": \"$HOST\",
  \"operatingSystem\": \"$OS\",
  {
    \"total\": $memTotal,
    \"free\": $memFree,
    \"used\": $memUsed,
    \"cache\": $memCached,
    \"swap\": $swapUsed
  },
  \"cpu\":
  {
    \"threads\": $cpuThreads,
    \"usedPercent\": $cpuUtilization
  },
  \"disk-usr/\": [
    $directory
  ]
}"

if [[ $parametr == "-r" ]] ;then
	echo "$JSON"

elif [[ $parametr == "-s" ]] ;then
	ping -c1 google.com &>/dev/null && echo "Check internet conection.....OK" || { echo "Check internet conection.....error"; return 1; }
	curl -d "@JSON" -X POST ${http} 2>dev/null && echo "Data was sent" || { echo "Problems with seding"; return 1; }
	#musim dotestovat
fi


}


if [[ $parametr == "-h" || $parametr == "-help" ||  $# == 0 ]];then
	echo -e "$LINE\nHelp for $NAME script :: version $VER\n$LINE\nUsage:\n\tProgram compute RAM, CPU informations and then sent to defined\n\taddrees at json format through curl POST\n\n\t-For adding script to crontab with runtime every minute add <-a> parametr\n\t-For showing what script to do add <-r> parametr\n\t-For send data through curl POST add <-s>\n$LINE"
elif [[  $parametr == "-a" ]];then
	cron && echo "Curl was successfully added" || { echo "Curl has some problems"; exit 1; }
elif [[  $parametr == "-r" || $parametr == "-s" ]];then
	main && echo "Script was successfully finished" || { echo "Script has some problems"; exit 1; }
else
	echo -e "Bad input.\nExiting..."
	exit 1
fi
