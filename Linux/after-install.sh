#!/bin/bash
# A simple script to initialise what is given on: https://sites.google.com/site/easylinuxtipsproject/mint-cinnamon-first

# Setup essential commands:

echo "Linux Mint (After Installation)"
echo "-----------------------------"
echo "These steps need to be followed: RUN TESTS FOR ALL COMMANDS WITHOUT PERMISSIONS"
echo


# 1) Improve settings for Synaptic Package Manager.
echo "-----------------------------------------"
echo "* When Synaptic Package Manager opens, go to:"
echo "* Making Changes (section) ->"
echo "TICK 'Consider recommended packages as dependencies'"
echo "-----------------------------------------"
echo
echo "-> Hit any key to open Synaptic Package Manager."
read
sudo synaptic &> /dev/null
echo
echo "-> Hit any key once you have set this."
read -n 1 -s
echo
echo "--> Setting 00recommends file from false to true."
if [[ "$EUID" -ne 0 ]]; then
    echo "-> Please enter your sudo password if prompted."
    sudo echo "s/false/true/g" >> /etc/apt/apt.conf.d/00recommends
    echo "> Set."
fi
echo


# 2) Change terminal transparency.
# echo -e "Would you like to set the transparency of the terminal to solid?"
# read yn
# select yn in "Yes" "No"
# case $yn in
#     Yes ) gconftool -s -t string /apps/gnome-terminal/profiles/Default/background_type solid;;
#     No ) exit;;
# esac

echo "2) Change terminal transparency to solid."
sudo gconftool -s -t string /apps/gnome-terminal/profiles/Default/background_type solid
echo "-> Set."
echo


# 3) Install encrypted DVD playback in VLC Media Player.
# echo
# echo "Would you like to install the libdvd package which enables the playback "
# echo "of encrupted DVD's in VLC Media Player? (Y OR any key for no)"
# read choice
# if [ choice == "Y"]; then
#     echo "--> Installing libdvd-pkg"
#     sudo apt-get -qq install libdvd-pkg
#     echo "-> Install finished."
# fi
# echo


# 4) Install useful system management tools.
echo "--> Installing useful system management tools:"
echo "    * Double Commander (Stand-alone file manager),"
echo "    * Leafpad (stand-alone text editor),"
echo "    * Pavucontrol (sound settings),"
echo "    * p7zip-rar (file extractor),"
echo "    * Catfish (finding files)."
echo
sudo apt-get -qq install doublecmd-gtk leafpad pavucontrol p7zip-rar catfish
echo "-> Installed doublecmd-gtk, leafpad, pavucontrol, p7zip-rar, catfish"
echo


# 5) Reduce use of swap.
echo "5) Edit the swap value."
swap_value=$(cat /proc/sys/vm/swappiness)
echo "-> The current swap value is: $swap_value"

if [ $swap_value >= "60" ]; then
    echo "--> The current value is high, reducing swap value to 10."
    sudo echo "vm.swappiness=10" >> /etc/sysctl.conf
fi
echo


# 6) Turn on the firewall.
echo "--> Turning on the firewall (ufw)."
sudo ufw enable    
echo "-> Firewall set, you can disable the firewall with: sudo ufw disable."
echo
echo "-> Hit any key to continue."
read


# 7) Install Microsoft fonts.
echo "--> Installing Microsoft fonts (ttf-mscorefonts-installer)"
sudo apt-get -qq install ttf-mscorefonts-installer
echo "-> Installed microsoft fonts."
echo


# 8) Remove Mono, gnome-orca and virtualbox-guest and install xpad.
# One by one option.
echo "--> Removing Mono, Gnome-Orca and VirtualBox-guest"
sudo apt-get -qq remove mono-runtime-common gnome-orca virtualbox-guest*
echo "-> Removed."
echo "-> The application Tomboy (if it was installed) would have been removed."
echo "--> Installing xpad to replace it."
sudo apt-get -qq install xpad
echo "-> Installed xpad."
echo


# 10) Disable hibernation (suspend-to-disk).
sourcefile=/etc/polkit-1/localauthority/50-local.d/com.ubuntu.enable-hibernate.pkla
if [ -f "$sourcefile" ]; then
    echo "--> Disabling hibernation (suspend-to-disk)."
    sudo mv -v $sourcefile /
    echo "-> You can move the file back with:"
    echo "sudo mv -v /com.ubuntu.enable-hibernate.pkla /etc/polkit-1/localauthority/50-local.d"
    echo "-> then with a reboot of your computer."
    echo
fi


# 11) Install DVD burning application (Xfburn).
# echo
# echo "Would you like to install the DVD burning application Xfburn? (Y or any key for no)"
# read choice
# if [ choice == "Y"]; then
#     echo "--> Installing Xfburn."
#     sudo apt-get -qq install xfburn
#     echo "-> Installed xfburn."
# fi
# echo


# 12) Disable user switching option.
echo "--> Setting switch user option to false."
gsettings set org.cinnamon.desktop.lockdown disable-user-switching true
echo "Turn it back on with: gsettings set org.cinnamon.desktop.lockdown disable-user-switching false"
echo "-> Set to true tick."
echo


# 13) Inode cache.
available_memory=$(grep MemTotal /proc/meminfo | awk '{print $2}')

echo "Your available memory: $available_memory"
if [ $available_memory > "1048576" ]; then
    echo "--> Setting VFS cache pressure"
    sudo echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.conf
    echo "-> Set."
fi
echo


# 14) Remove indexing application apt-xapian-index and plumbing for VirtualBox
if [ $available_memory < "1048576" ]; then
    echo "Would you like to remove indexing application apt-xapian-index?"
    echo "The quick search in Synaptic Package Manager will be removed, but you"
    echo "may use the search button (magnifying glass icon in panel of Synaptic."
    echo -e "This is ideal for older systems (Y/y)"
    read choice
    if [ choice == "Y" || choice == "y" ]; then
        echo "--> Removing apt-xapian-index"
        sudo apt-get -qq purge apt-xapian-index
        echo "-> Removed apt-xapian-index"
    fi
fi
echo


# 15) Remove plumbing for VirtualBox in Linux.
echo "Would you like to remove plumbing for VirtualBox, you might"
echo -e "this if virtualbox was already uninstalled (Y)"
read choice
if [ choice == "Y" || choice == "y" ]; then
    echo "--> Removing virtual box."
    sudo apt-get -qq purge virtualbox*
    echo "-> Removed"
fi
echo


# 16) Speed up system by placing /tmp on /tmpfs partition.
if [ $available_memory > 4500000 ]; then
    echo "More than 4GB available memory, placing temporary files"
    echo "from hard disk into virtual RAM"
    echo "--> Moving /tmp to /tmpfs."
    sudo cp -v /usr/share/systemd/tmp.mount /etc/systemd/system/
    echo "--> Mounting tmp."
    sudo systemctl enable tmp.mount
    echo "You can undo this by: sudo rm -v /etc/systemd/system/tmp.mount"
fi
echo


# 17) Disable Bluetooth from starting up on its own.
bluetooth_configuration="""
[Desktop Entry]
Type=Application
Exec=rfkill block bluetooth
X-GNOME-Autostart-enabled=true
NoDisplay=false
Hidden=false
Name[en_GB]=Disable Bluetooth
Comment[en_GB]=Disables bluetooth in starting up.
X-GNOME-Autostart-Delay=0
"""

echo "--> Setting command to stop bluetooth starting up."
echo "$bluetooth_configuration" > ~/.config/autostart/Disable\ Bluetooth.desktop
echo "-> Wrote 'Disable Bluetooth.desktop'   file to ~/.config/autostart/"
echo "-> You can remove it from the directory to stop it if needed."
echo


# 18) Install backup software: TimeShift.
echo "--> Setting up TimeShift (http://www.teejeetech.in/p/timeshift.html)."
echo "--> Adding PPA: teejee2008/ppa"
sudo apt-add-repository -y ppa:teejee2008/ppa > /dev/null 2>&1
echo "-> Added PPA: teejee2008/ppa"
echo "--> Update apt"
sudo apt-get -qq update
echo "-> Updated apt."
echo "--> Installing TimeShift."
sudo apt-get -qq install timeshift
echo "-> Installed TimeShift."
echo


# Finish off the installation.
echo "-> Please restart the computer."



# Select update policy: https://sites.google.com/site/easylinuxtipsproject/mint-cinnamon-first#TOC-Select-an-update-policy-and-apply-all-available-updates
# SSD: https://sites.google.com/site/easylinuxtipsproject/ssd
# Optimize firefox: https://sites.google.com/site/easylinuxtipsproject/firefox
# Tweak Libre Office: https://sites.google.com/site/easylinuxtipsproject/libreoffice
# Install Google Chrome: https://www.google.com/chrome/browser/desktop/
# Speed up Linux Mint: https://sites.google.com/site/easylinuxtipsproject/3
# Customize Grub boot menu: https://sites.google.com/site/easylinuxtipsproject/beautifygrub
# Clean up Linux Mint: https://sites.google.com/site/easylinuxtipsproject/4
#
# Install specific pieces of software:
#
# Transparent Panels: Menu -> Preferences -> Extensions -> Available Extensions (Online) -> Transparent Panels. Set to semi-transparent.
# Java JDK: https://community.linuxmint.com/tutorial/view/1372
# Wine from repository and winetricks.sh file.
# Python2 and Python3, install pip with python2 -m easy_install pip or python3 -m easy_install pip.
# Timeshift: ppa:teejee2008/ppa
# Android SDK -> virtualization: https://github.com/uw-it-aca/spacescout-android/wiki/1.-Setting-Up-Android-Studio-on-Ubuntu, remove libvirt not running any guests:
# apt-get autoremove --purge
# Save brightness settings after restart: sudo add-apt-repository ppa:nrbrtx/sysvinit-backlight, sudo apt-get update, sudo apt-get install sysvinit-backlight
# Power usage: ppa:linrunner/tlp, install tlp-rdw.
# New-Minty: themes online -> new minty theme.
# uninstall linux mint from PC: https://www.tweaking4all.com/os-tips-and-tricks/remove-ubuntu-windows-uefi-dualboot/





