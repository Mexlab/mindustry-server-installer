#!/bin/bash
#this script will install all reqirements for Mindustry
#check if root
if [ $EUID -eq 0 ]; then
isroot="true"

read -p "This script will do various changes on your device, only continue if you know what you're doing [y/n] " tans #check users agreement
if [ "$tans" != "y" ]; then
echo "exit"
exit 1
fi

else
echo "Err: this script needs to be root"
exit 1
fi

echo ""
function ireq {
#check if java is installed & install requirements
test "java -version" > /dev/null
if [ "$?" -eq "0" ]; then

#install whit java 17
echo ""
echo "installing some requirements..."
echo ""
apt update
echo""
apt install git whiptail curl neofetch screen jq -y
apt install openjdk-17-jdk -y || echo "" && echo "cannot install Java 17, installing java 11" && echo "" && sleep 3 && apt install openjdk-11-jdk -y

else
echo "You have already java installed, for mods and plugins it's recommended to install java 17. This report appears even java 17 is installed!"
echo "the installed java version is:"
java -version
echo ""
read -s -p "press enter" -n 1
#installing whitout java
echo ""
echo "installing some requirements"
echo ""
apt update
echo ""
apt install git whiptail curl neofetch screen jq -y
fi

}
#further setup

#create new User
function auser {
shouldroot="true"
user=$(whiptail --inputbox "please set name of new user:" 8 39 --title "Mindustry Server Setup" 3>&1 1>&2 2>&3)
if [ "$shouldroot" = "true" ]; then
adduser $user --gecos "" --disabled-password --ingroup sudo
else
adduser $user --gecos "" --disabled-password
fi

local tans="please enter password of new user"
while true; do
password=$(whiptail --passwordbox "$tans" 8 39 --title "Mindustry Server Setup" 3>&1 1>&2 2>&3)
if [ $? -eq "1" ]; then
return 1
break
fi
local rpassword=$(whiptail --passwordbox "please reenter password of new user" 8 39 --title "Mindustry Server Setup" 3>&1 1>&2 2>&3)
if [ $? -eq "1" ]; then
return 1
break
fi

if [ "$password" == "$rpassword" ]; then
echo "$user:$password" |chpasswd 
echo "/etc/skel/.bashrc" > "/home/$user/.bashrc"
return 0
break
else
tans="failed, please enter password of new user"
fi
done

}
#choose existing user

function exuser {
local allusers+=$(awk -F ":" '/home/ {print $1}' /etc/passwd | sort)
local tans="Input existing user please choose an user whit homelocation at /home/* "

while true; do
user=$(whiptail --inputbox "$tans" 8 60 --title "w" 3>&1 1>&2 2>&3)   #pls replace whit radiolist

if [ grep -o $user ]; then   #not secure
return 0
break

else
local tans="This User does not exists"
fi
done
return 1
}


function chooseuser {

local tans=$(whiptail --title "Mindustry Server Setup" --menu "please choose one option, the user will store all config and data" 16 100 9 \
      "1)" "existing user" \
      "2)" "add new user" 3>&2 2>&1 1>&3)

case $tans in
      "1)")
        exuser
	if [ $? -eq 1 ]; then
	echo "Err: can't choose user"
	exit 1
	fi
      ;;
      "2)")
        auser
	if [ $? -eq 1 ]; then
        echo "Err: can't create new user"
        exit 1
	fi
      ;;
   esac

}


function nconfig {

cd /home/$user/
#remove old configs
rm -r /home/$user/.mdconfig
#config dir
mkdir /home/$user/.mdconfig
git clone https://github.com/Mexlab/mindustry-server-installer.git
mv -f /home/$user/mindustry-server-installer /home/$user/.mdconfig
cat /home/$user/.profile > /home/$user/.bash_profile
cat /home/$user/.mdconfig/mindustry-server-installer/motd.sh >> /home/$user/.bash_profile
cp /home/$user/.mdconfig/mindustry-server-installer/* /home/$user/.mdconfig/
grep -v "alias md" /home/$user/.bashrc > /home/$user/.bashrc
echo "alias md=\"/home/$user/.mdconfig/main.sh\"" >> /home/$user/.bashrc
mkdir /home/$user/mindustryimages
mkdir /home/$user/mindustryserver
sudo hostname -b mindustry-server
homedir="/home/$user"
firstsetup="true"
autoupdate="true"
echo "user=\"$user\"" >> /home/$user/.mdconfig/inf.conf
echo "shouldroot=\"$shouldroot\"" >> /home/$user/.mdconfig/inf.conf
echo "homedir=\"$homedir\"" >> /home/$user/.mdconfig/inf.conf
echo "autoupdate=\"$autoupdate\"" >> /home/$user/.mdconfig/inf.conf
echo "succecsfull updated inf.conf"
}

function sysreboot {
if [ "$fistsetup" == "true" ]; then
local tans="To apply some changes to system need to reboot, after reboot you should login as $user"
else
local tans="Reboot the system?"
fi
if (whiptail --title "Mindustry Server Setup" --yesno "$tans" 8 78); then
reboot
else
exit 1
fi
}

ireq
if [ "$?" -eq 1 ];then
echo "can't install requierements"
exit 1
fi
chooseuser
if [ "$?" -eq 1 ];then
echo "you doesn't choose an user"
exit 1
fi
nconfig
if [ "$?" -eq 1 ];then
echo "can't config"
exit 1
fi
sysreboot
if [ "$?" -eq 1 ];then
echo "no reboot"
exit 1
fi
firstsetup="false"
echo "firstsetup=\"$firstsetup\"" >> /home/$user/.mdconfig/inf.conf
chown -cR $user $userdir

exit 0
