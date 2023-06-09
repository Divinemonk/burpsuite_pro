#!/bin/bash

# [dev]   : A Divinemonk creation!
# [git]   : https://github.com/Divinemonk/burpsuite_pro
# [script]: install_script.sh

# BURPSUITE PRO installer: for linux (debian based distros)


# ------------------------------------LOGO---------------------------------------
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo " [prog] : Burp Suite Pro Installer"
echo " [dev]  : A Divinemonk creation!"
echo " [git]  : https://github.com/Divinemonk/burpsuite_pro"
echo " [creds]: https://github.com/h3110w0r1d-y/BurpLoaderKeygen"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
printf "\n" 


# ------------------------------CHECKING REQUIREMENTS---------------------------

# check if we are running as root
if [ "$EUID" -ne 0 ]
then 
    echo "[!] Please run as root"
    printf "\n"
    exit
fi

# check for internet connection
if ! ping -q -c 1 -W 1 google.com >/dev/null;
then
    echo "[!] No internet connection. Please check your internet connection."
    printf "\n"
    exit
fi


# check if required packages are installed (wget, java)
exit_flag=0
if ! command -v java &> /dev/null
then
    echo "[!] Java is not installed. Please install java first."
    exit_flag=1
elif ! command -v wget &> /dev/null
then
    echo "[!] wget is not installed. Please install wget first."
    exit_flag=1
fi

# exit program if any of the required packages are not installed
if [ $exit_flag -eq 1 ]
then
    printf "\n"
    exit
fi


# ---------------------------------DOWNLOADING DEPENDENCIES---------------------------------

# Download latest `BurpLoaderKeygen.jar` from github (https://github.com/h3110w0r1d-y/BurpLoaderKeygen)
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo "[#] DOWNLOADING DEPENDENCIES"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
echo "[+] Downloading BurpLoaderKeygen.jar from github..."
wget "https://github.com/h3110w0r1d-y/BurpLoaderKeygen/releases/latest/download/BurpLoaderKeygen.jar" -q > /dev/null

# Get the latest burpsuite pro version (from https://portswigger.net/burp/releases)
echo "[+] Getting the latest burpsuite pro version..."
curl https://portswigger.net/burp/releases -s > burp.html

# get the version number from html page
version=$(cat burp.html | grep /burp/releases/professional-community)
version=$(echo $version | cut -d'>' -f1 | cut -d'-' -f3-5 | cut -d'"' -f1 | sed 's/-/./g')
rm burp.html

# download the latest burpsuite pro version
echo "[+] Downloading burpsuite pro v$version from portswigger.net..."
echo "[i] This may take some time, please wait..."
wget "https://portswigger-cdn.net/burp/releases/download?product=pro&version=$version&type=jar" -o burpsuite_pro_v$version.jar -q > /dev/null

# rename the downloaded file to burpsuite_pro_v<version>.jar
mv "download?product=pro&version=$version&type=jar" burpsuite_pro_v$version.jar
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
printf "\n"


# --------------------------------------INSTALLATION---------------------------------------------

# Installing burpsuite pro
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo "[#] INSTALLING burpsuite PRO (v$version)"
echo "[i] Press enter/enter blank for default values."
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

# Getting username to license burpsuite pro
read -p "[+] Enter your username to license burpsuite pro (default: $USER): " username
if [ -z "$username" ] # if username is empty
then
    username=$USER
fi

# Create the burp terminal command
read -p "[+] Enter burpsuite pro terminal command (default: burp): " burp
if [ -z "$burp" ] # if burp is empty
then
    burp="burp"
elif [ -f "/usr/bin/$burp" ] # check if $burp is already in /usr/bin
then
    echo "[-] $burp already exists in /usr/bin. Please enter a different name or delete the existing file (sudo rm /usr/bin/$burp).)"
    printf "\n"
    exit 
fi

# Getting installation directory
read -p "[+] Enter installation directory (default: /opt/$burp): " install_dir

if [ -z "$install_dir" ] # if install_dir is empty
then
    install_dir="/opt/$burp"
    if [ -d "$install_dir" ] # check if $install_dir already exists
    then
        echo "[-] $install_dir already exists. Please enter a different directory or delete the existing directory (sudo rm -rf $install_dir)."
        printf "\n"
        exit
    fi
elif [ -d "$install_dir" ] # check if $install_dir already exists
then
    echo "[-] $install_dir already exists. Please enter a different directory or delete the existing directory (sudo rm -rf $install_dir)."
    printf "\n"
    exit
fi

mkdir $install_dir
echo "[+] Moving downloaded files to $install_dir..."
mv ./BurpLoaderKeygen.jar ./burpsuite_pro_v$version.jar $install_dir


# Creating burpsuite pro scripts
# writing config file
cat > $install_dir/.config.ini <<EOF
ignore=1
auto_run=1
EOF

# install script
cp install_burppro.sh $install_dir
chmod +x $install_dir/install_burppro.sh

# uninstall script
cat > $install_dir/uninstall_burppro.sh <<EOF
#!/bin/bash

# [dev]   : A Divinemonk creation!
# [git]   : https://github.com/Divinemonk/burpsuite_pro
# [script]: uninstall_burppro.sh

sudo rm -rf $install_dir /usr/bin/$burp
EOF
chmod +x $install_dir/uninstall_burppro.sh

# run script
cat > $install_dir/run_burppro.sh <<EOF
#!/bin/bash

# [dev]   : A Divinemonk creation!
# [git]   : https://github.com/Divinemonk/burpsuite_pro
# [script]: run_burppro.sh

java -jar $install_dir/BurpLoaderKeygen.jar -a -i 1 -n "$username" >/dev/null
EOF
chmod +x $install_dir/run_burppro.sh

# update script
cat > $install_dir/update_burppro.sh <<EOF
#!/bin/bash

# [dev]   : A Divinemonk creation!
# [git]   : https://github.com/Divinemonk/burpsuite_pro
# [script]: update_burppro.sh

# check if we are running as root
if [ "\$EUID" -ne 0 ]
then 
    echo "[!] Please run as root"
    printf "\n"
    exit
fi

# check for internet connection
if ! ping -q -c 1 -W 1 google.com >/dev/null;
then
    echo "[!] No internet connection. Please check your internet connection."
    printf "\n"
    exit
fi

printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo "[#] CHECKING IF UPDATE IS AVAILABLE"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

# Get the latest burpsuite pro version (from https://portswigger.net/burp/releases)
echo "[+] Getting the latest burpsuite pro version..."
curl https://portswigger.net/burp/releases -s > burp.html

# get the version number from html page
version=\$(cat burp.html | grep /burp/releases/professional-community)
version=\$(echo \$version | cut -d'>' -f1 | cut -d'-' -f3-5 | cut -d'"' -f1 | sed 's/-/./g')
rm burp.html

# printing the latest version
printf "\n"
echo "[+] Latest version of BURPSUITE PRO: \$version"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =

# check if the latest version is already installed
if [ -f "$install_dir/burpsuite_pro_v\$version.jar" ]
then
    echo "[+] You already have the latest version installed."
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
    printf "\n"
    exit
fi

printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo "[#] UPDATE AVAILABLE"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
printf "\n"

printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo "[#] DOWNLOADING DEPENDENCIES"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
echo "[+] Downloading BurpLoaderKeygen.jar from github..."
wget "https://github.com/h3110w0r1d-y/BurpLoaderKeygen/releases/latest/download/BurpLoaderKeygen.jar" -q > /dev/null

# download the latest burpsuite pro version
echo "[+] Downloading burpsuite pro v\$version from portswigger.net..."
wget "https://portswigger-cdn.net/burp/releases/download?product=pro&version=\$version&type=jar" -q > /dev/null

# rename the downloaded file to burpsuite_pro_v<version>.jar
mv 'download?product=pro&version=2023.5.2&type=jar' burpsuite_pro_v\$version.jar
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
printf "\n"

printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo "[#] UPDATING DEPENDENCIES"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
echo "[+] Updating BurpLoaderKeygen.jar..."
mv BurpLoaderKeygen.jar $install_dir
echo "[+] Updating burpsuite_pro_v\$version.jar..."
mv burpsuite_pro_v\$version.jar $install_dir
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
echo "[+] UPDATED DEPENDENCIES SUCCESSFULLY!"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
printf "\n"
EOF
chmod +x $install_dir/update_burppro.sh

# setup run & uninstall command 
# run command: $burp
# uninstall command: sudo $burp uninstall
cat > $burp <<EOF
#!/bin/bash 

# [dev]   : A Divinemonk creation!
# [git]   : https://github.com/Divinemonk/burpsuite_pro
# [script]: /usr/bin/$burp

# check if uninstall command is passed
printf "\n"
if [ "\$1" == "uninstall" ]
then
    # check if we are running as root
    if [ "\$EUID" -ne 0 ]
    then 
        echo "[!] Please run as root"
        printf "\n"
        exit
    fi

    # comfirming uninstallation
    echo "[!] Last chance to abort uninstallation of burpsuite pro! Abort? [Y/n]:"
    read confirm
    if [ "\$confirm" != "y" ] && [ "\$confirm" != "Y" ]
    then
        echo "[#] Uninstallation aborted!"
        printf "\n"
        exit
    fi

    # uninstalling burpsuite pro
    echo "[+] Uninstalling burpsuite pro..."
    $install_dir/uninstall_burppro.sh
    echo "[#] Burpsuite pro uninstalled successfully!"
    printf "\n"
    exit
elif [ "\$1" == "update" ]
then
    # check if we are running as root
    if [ "\$EUID" -ne 0 ]
    then 
        echo "[!] Please run as root"
        printf "\n"
        exit
    fi

    # updating burpsuite pro
    echo "[+] Updating burpsuite pro..."
    $install_dir/update_burppro.sh
    echo "[#] Burpsuite pro updated successfully!"
    printf "\n"
    exit
else
    # runnning burpsuite pro
    $install_dir/run_burppro.sh
fi
EOF

# creating burpsuite pro terminal command
echo "[+] Creating burpsuite pro terminal command..."
mv $burp /usr/bin/
chmod +x /usr/bin/$burp
echo "[+] Burpsuite pro terminal command created successfully!"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
printf "\n"


# -------------INSTALLATION COMPLETE: PRINT DETAILS------------------

# Print details of downloaded files
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo "[@] INSTALLATION COMPLETED SUCCESSFULLY!"
printf "\n"
echo "[#] Details of downloaded files:"
echo "    - $install_dir/BurpLoaderKeygen.jar"
echo "    - $install_dir/burpsuite_pro_v$version.jar"
printf "\n"
echo "[#] Details of burpsuite pro license:"
echo "    - username: $username"
echo "    - license type: Professional"
echo "    - license duration: lifetime"
printf "\n"
echo "[#] Details of burpsuite pro terminal command:"
echo "    - command: $burp (/usr/bin/$burp)"
echo "    - installation directory: $install_dir"
printf "\n"
echo "[#] Run/Install/Update/Uninstall scripts location:"
echo "    - $install_dir/run_burppro.sh"
echo "    - $install_dir/install_burppro.sh"
echo "    - $install_dir/uninstall_burppro.sh"
echo "    - $install_dir/update_burppro.sh"
printf "\n"
echo "[#] Uninstall burpsuite pro using the following command:"
echo "    - sudo $burp uninstall"
echo "    - sudo rm -rf $install_dir /usr/bin/$burp"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
echo "[i] Available options/commands:"
echo "    - $burp                 (run/start burpsuite pro)"
echo "    - sudo $burp uninstall  (uninstall burpsuite pro)"
echo "    - sudo $burp update     (update burpsuite pro)"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
printf "\n"




# create the burpsuite pro desktop entry
# echo "[+] Writing burpsuite pro desktop entry..."
# echo "[Desktop Entry]
# Name=burpsuite Pro
# Comment=Web Security Testing Tool
# Exec=java -jar /opt/burpsuite_pro/burpsuite_pro_v$version.jar
# Icon=/opt/burpsuite_pro/burp.png
# Terminal=false
# Type=Application
# Categories=Utility;Application;" > burpsuite_pro.desktop
