#!/bin/bash
#this file contains some content for 

clear

echo "$(tput bold)"
echo "$(tput setaf 27) __  __ _           _           _              $(tput setaf 1)     $(tput setaf 6)  ___  ____   "
echo "$(tput setaf 27)|  \/  (_)_ __   __| |_   _ ___| |_ _ __ _   _ $(tput setaf 1)     $(tput setaf 6) / _ \/ ___|  "
echo "$(tput setaf 27)| |\/| | |  _ \ / _  | | | / __| __|  __| | | |$(tput setaf 1)_____$(tput setaf 6)| | | \___ \  "
echo "$(tput setaf 27)| |  | | | | | | (_| | |_| \__ \ |_| |  | |_| |$(tput setaf 1)_____$(tput setaf 6)| |_| |___) | "
echo "$(tput setaf 27)|_|  |_|_|_| |_|\__,_|\__,_|___/\__|_|   \__, |$(tput setaf 1)     $(tput setaf 6) \___/|____/  "
echo "$(tput setaf 27)                                         |___/ $(tput setaf 1)     $(tput setaf 6)              "

let upSeconds="$(/usr/bin/cut -d. -f1 /proc/uptime)"
let secs=$((${upSeconds}%60))
let mins=$((${upSeconds}/60%60))
let hours=$((${upSeconds}/3600%24))
let days=$((${upSeconds}/86400))
UPTIME=`printf "%d days, %02dh%02dm%02ds" "$days" "$hours" "$mins" "$secs"`

# get the load averages
read one five fifteen rest < /proc/loadavg

echo "$(tput setaf 2)
`date +"%A, %e %B %Y, %r"`
`uname -srmo`

$(tput sgr0)- Uptime.............: ${UPTIME}
$(tput sgr0)- Memory.............: `free | grep Mem | awk '{print $3/1024}'` MB (Used) / `cat /proc/meminfo | grep MemTotal | awk {'print $2/1024'}` MB (Total)
$(tput sgr0)- Load Averages......: ${one}, ${five}, ${fifteen} (1, 5, 15 min)
$(tput sgr0)- Running Processes..: `ps ax | wc -l | tr -d " "`
$(tput sgr0)- IP Addresses.......: `hostname -I | /usr/bin/cut -d " " -f 1` and `wget -q -O - http://icanhazip.com/ | tail`

$(tput sgr0)"
