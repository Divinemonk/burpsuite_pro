#!/bin/bash

##############################################################
# [prog]  : Burp Suite Pro Installer Script                  #
# [dev]   : A Divinemonk creation!                           #
# [git]   : https://github.com/Divinemonk/burpsuite_pro      #
# [ver]   : v1.0.1                                           #
# [desc]  : Install Burp Suite Pro on Linux (debian based)   #
############################################################## 


# check if we are running as root
if [ "$EUID" -ne 0 ]
then 
    printf "\n"
    echo "[!] Please run as root"
    printf "\n"
    exit
fi

# check for internet connection
if ! ping -q -c 1 -W 1 google.com >/dev/null;
then
    printf "\n"
    echo "[!] No internet connection. Please check your internet connection."
    printf "\n"
    exit
fi

# Download installer
wget "https://github.com/Divinemonk/burpsuite_pro/releases/latest/download/install_burppro.sh" -q >/dev/null

# run installer
chmod +x install_burppro.sh
./install_burppro.sh

# clean up
rm install_burppro.sh
