#!/bin/bash

# A script to install the essential packages that I use on Ubuntu 18.04.
# TODO: Auto yes (-y or echo yes | command)

echo "Ubuntu 18.04 (After Installation)"
echo "---------------------------------"
echo "IMPORTANT: Make sure you are connected to internet (if wifi drivers are not present)"
echo

echo "-> Updating apt (provide sudo password)..."
sudo apt-get update
echo "---------------------------------------"
echo


# 1) Install git, dkms, build-essential for current linux kernel:
echo "-> Installing git, dkms, build-essential"
sudo apt-get install --reinstall git dkms build-essential linux-headers-$(uname -r)
echo "----------------------------------------"
echo


# 2) Install wifi drivers.
echo "-> Installing wifi drivers for rtl8821ce"
chmod +x rtl8821ce/dkms-install.sh
chmod +x dkms-remove.sh
sudo rtl8821ce/dkms-install.sh
echo "----------------------------------------"
echo


